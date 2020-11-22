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

Component that listens for and processes control signals. The `state` field
stores the current state of the processing unit.
"""
struct ControlUnit
    #=
      Fields
      ------
      * `state`: operational state

      * `control_url`: URL that ControlUnit listens for control signals on

      * `control_socket`: ZMQ Socket for receiving control signals and
                          returning status
    =#
    state::AbstractControlState
    control_url::String
    control_socket::Socket

    function ControlUnit(state::AbstractControlState,
                         control_url::String;
                         copy_state=true,
                         use_bind=true)

        # Create Socket to listen for control signals
        control_socket = Socket(REP)

        # Connect socket to URL
        if use_bind
            bind(control_socket, control_url)
        else
            connect(control_socket, control_url)
        end

        # Return new ControlUnit
        if copy_state
            new(deepcopy(state), control_url, control_socket)
        else
            new(state, control_url, control_socket)
        end
    end
end

# --- Method definitions

function run(control_unit::ControlUnit;
             node::Union{AbstractNode, Nothing}=nothing)
    # Wait for control signal
    message = recv(control_unit.control_socket, Vector{UInt8})
    control_signal = decode_control_signal(typeof(control_unit.state), message)

    # Process control signal
    try
        response = process_control_signal!(control_unit.state, control_signal)
    catch
        response = get_exception_signal(typeof(control_unit.state))
    end

    # Send response
    if isnothing(response)
        response = ""
    end
    send(control_unit.control_socket, response)

    # Restart control unit
    @async run(control_unit, node=node)
end
