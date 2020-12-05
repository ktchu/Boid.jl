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

# --- Type definitions

using ZMQ

"""
    struct ControlUnit

Component that listens for and processes control signals. The `logic_unit`
field (1) provides methods to handle control signals and (2) stores the
current control state (if any).
"""
struct ControlUnit
    #=
      Fields
      ------
      * `logic_unit`: control logic unit

      * `url`: URL that ControlUnit listens for control signals on

      * `socket`: ZMQ Socket for receiving control signals and
                          returning status
    =#
    logic_unit::AbstractControlLogicUnit
    url::String
    socket::Socket
end

"""
    ControlUnit(logic_unit::AbstractControlLogicUnit,
                url::String;
                copy_logic_unit=true,
                use_bind=true)

Construct a control unit ... TODO
"""
function ControlUnit(logic_unit::AbstractControlLogicUnit,
                     url::String;
                     copy_logic_unit=true,
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
    if copy_logic_unit
        ControlUnit(deepcopy(logic_unit), url, socket)
    else
        ControlUnit(logic_unit, url, socket)
    end
end

# --- Method definitions

function run(control_unit::ControlUnit)
    # Wait for control signal
    message = recv(control_unit.socket, Vector{UInt8})
    control_signal = decode_control_signal(typeof(control_unit.logic_unit),
                                           message)

    # Process control signal
    try
        response = process_control_signal!(control_unit.logic_unit,
                                           control_signal)
    catch
        response = get_exception_signal(typeof(control_unit.logic_unit))
    end

    # Send response
    if isnothing(response)
        response = ""
    end
    send(control_unit.socket, response)

    # Restart control unit
    @async run(control_unit)
end
