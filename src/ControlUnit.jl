"""
The ControlUnit.jl module defines the ControlUnit type and methods

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Exports

# ------ Types

export ControlUnit
export BuiltInControlSignal
export ControlUnitResponse

# ------ Functions

export run!, process_control_signal!
export is_running, is_terminated
export wait_for_input_ready

# --- Type definitions

using ZMQ

"""
    enum ControlUnitState

Built-in control unit states.
"""

@enum ControlUnitState begin
    NOT_RUNNING
    RUNNING
    TERMINATED
end

"""
    enum ControlUnitResponse

Built-in control unit responses.
"""

@enum ControlUnitResponse begin
    SUCCESS
    FAILED
    UNKNOWN_SIGNAL
end

"""
    enum BuiltInControlSignal

Built-in control unit signals.

TODO: document reserved control signal values, including "nothing"
"""

@enum BuiltInControlSignal::Int8 begin
    START = -1
    STOP = -2
    TERMINATE = -3
end

BUILT_IN_CONTROL_SIGNALS = instances(BuiltInControlSignal)

"""
    struct ControlUnit

Component that listens for and processes control signals. The `logic_core`
field (1) provides methods to handle control signals and (2) stores the
current control state (if any).
"""
struct ControlUnit
    #=
      Fields
      ------
      * `state`: control unit state

      * `logic_core`: control logic core

      * `url`: URL that ControlUnit listens for control signals on

      * `socket`: ZMQ Socket for receiving control signals and
                          returning status
    =#
    state::Dict
    logic_core::AbstractControlLogicCore
    url::String
    socket::Socket
end

"""
    ControlUnit(logic_core::AbstractControlLogicCore,
                url::String;
                copy_logic_core=true,
                use_bind=true)

Construct a control unit ... TODO
"""
function ControlUnit(logic_core::AbstractControlLogicCore,
                     url::String;
                     copy_logic_core=true,
                     use_bind=true)

    # Initialize state
    state = Dict("mode"=>NOT_RUNNING)

    # Create Socket to listen for control signals
    socket = Socket(REP)

    # Connect socket to URL
    if use_bind
        bind(socket, url)
    else
        connect(socket, url)
    end

    # Return new ControlUnit
    if copy_logic_core
        ControlUnit(state, deepcopy(logic_core), url, socket)
    else
        ControlUnit(state, logic_core, url, socket)
    end
end

# --- Method definitions

"""
    run!(control_unit::ControlUnit)

Start control signal processing loop for `control_unit`.
"""
function run!(control_unit::ControlUnit)
    # Set state to RUNNING
    control_unit.state["mode"] = RUNNING

    # Start control signal processing loop within a Task
    @async begin
        while !is_terminated(control_unit)
            process_control_signal!(control_unit)
        end
    end
end

"""
    process_control_signal!(control_unit::ControlUnit)

Receive and process next control signal.
"""
function process_control_signal!(control_unit::ControlUnit)
    # --- Wait for control signal

    message = recv(control_unit.socket, Vector{UInt8})

    # --- Decode message

    signal = nothing

    # Attempt to interpret as a built-in control signal
    try
        signal = reinterpret(BuiltInControlSignal, message)[1]
        if !(signal in BUILT_IN_CONTROL_SIGNALS)
            throw(ArgumentError)
        end
    catch ArgumentError
        signal = nothing
    end

    # Attempt to interpret as a custom control signal
    if isnothing(signal)
        try
            signal = decode_control_signal(typeof(control_unit.logic_core),
                                           message)
        catch ArgumentError
            signal = nothing
        end
    end

    # --- Process signal

    # Handle unknown and invalid signals
    if isnothing(signal)
        response = UNKNOWN_SIGNAL
        send(control_unit.socket, response)
        return
    end

    # Process valid signal
    if signal in BUILT_IN_CONTROL_SIGNALS
        try
            response = _process_built_in_control_signal!(control_unit, signal)
        catch
            response = FAILED

            # TODO: add log message
        end
    else
        # Process custom control signals
        try
            response = process_control_signal!(control_unit.logic_core, signal)
        catch
            response = FAILED

            # TODO: add log message
        end
    end

    # --- Send response

    if isnothing(response)
        response = ""
    end
    send(control_unit.socket, response)
end

"""
    is_running(control_unit::ControlUnit)

Return true if the `control_unit` is RUNNING state; return false otherwise.
"""
is_running(control_unit::ControlUnit) = control_unit.state["mode"] == RUNNING

"""
    is_terminated(control_unit::ControlUnit)

Return true if the `control_unit` is TERMINATED state; return false otherwise.
"""
is_terminated(control_unit::ControlUnit) =
    control_unit.state["mode"] == TERMINATED

"""
    wait_for_input_ready(control_unit::ControlUnit,
                         input_channels::Vector{InputChannel})

Wait for input channels to be ready for processing.
"""
function wait_for_input_ready(control_unit::ControlUnit,
                              input_channels::Vector{InputChannel})

    wait_for_input_ready(control_unit.logic_core, input_channels)
end

# --- Private helper functions

"""
    _process_built_in_control_signal!(control_unit::ControlUnit, signal)

Process built-in control signals. Return response
"""
function _process_built_in_control_signal!(control_unit::ControlUnit, signal)

    if signal == START
        control_unit.state["mode"] = RUNNING
    elseif signal == STOP
        control_unit.state["mode"] = NOT_RUNNING
    elseif signal == TERMINATE
        control_unit.state["mode"] = TERMINATED
    else
        return UNKNOWN_SIGNAL
    end

    return SUCCESS
end
