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

# ------ Functions

import Base.run
export is_running, wait_for_input_ready

# --- Type definitions

using ZMQ

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
      * `logic_core`: control logic core

      * `url`: URL that ControlUnit listens for control signals on

      * `socket`: ZMQ Socket for receiving control signals and
                          returning status
    =#
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
        ControlUnit(deepcopy(logic_core), url, socket)
    else
        ControlUnit(logic_core, url, socket)
    end
end

# --- Method definitions

"""
    run(control_unit::ControlUnit)

Start control signal processing loop.
"""
function run(control_unit::ControlUnit)
    # Set control logic core to 'running' state
    set_running!(control_unit.logic_core)

    # Control signal processing loop
    while is_running(control_unit)

        # Wait for control signal
        message = recv(control_unit.socket, Vector{UInt8})
        control_signal = decode_control_signal(typeof(control_unit.logic_core),
                                               message)

        # Process control signal
        try
            response = process_control_signal!(control_unit.logic_core,
                                               control_signal)
        catch
            response = get_exception_signal(typeof(control_unit.logic_core))
        end

        # Send response
        if isnothing(response)
            response = ""
        end
        send(control_unit.socket, response)
    end
end

"""
    is_running(control_unit::ControlUnit)

Return true if the Node is running; return false otherwise.
"""
is_running(control_unit::ControlUnit) = is_running(control_unit.logic_core)

"""
    wait_for_input_ready(control_unit::ControlUnit,
                         input_channels::Vector{InputChannel})

Wait for input channels to be ready for processing.
"""
function wait_for_input_ready(control_unit::ControlUnit,
                              input_channels::Vector{InputChannel})

    wait_for_input_ready(control_unit.logic_core, input_channels)
end
