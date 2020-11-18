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
    ControlUnit

TODO
"""
struct ControlUnit
    #=
      Fields
      ------
      * `state`: operational state

      * `control_url`: URL that ControlUnit listens for control signals on

      * `control_channel`: channel for receiving control signals and returning
                           status
    =#
    state::AbstractControlState
    control_url::String
    control_channel::Socket

    function ControlUnit(state::AbstractControlState,
                         control_url::String;
                         copy_state=true,
                         use_bind=true)

        # Create Socket to listen for control signals on
        control_channel = Socket(REP)

        # Connect socket to URL
        if use_bind
            bind(control_channel, control_url)
        else
            connect(control_channel, control_url)
        end

        # Return new ControlUnit
        if copy_state
            new(deepcopy(state), control_url, control_channel)
        else
            new(state, control_url, control_channel)
        end
    end
end

# --- Method definitions

function run(control_unit::ControlUnit)
    # Wait for control signal
    message = recv(control_unit.control_channel, Vector{UInt8})
    control_signal = decode_control_signal(typeof(control_unit.state), message)

    # Process control signal
    try
        response = process_control_signal!(control_signal, control_unit.state)
    catch
        response = get_exception_signal(typeof(control_unit.state))
    end

    # Send response
    if isnothing(response)
        response = ""
    end
    send(control_unit.control_channel, response)

    # Restart control unit
    @async run(control_unit)
end
