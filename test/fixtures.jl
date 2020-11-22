"""
Fixtures for unit tests.

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Constants

control_url = construct_ipc_url(".", "control-unit-test.zmq")
ipc_path = control_url[7:end]

# --- ControlState

mutable struct ControlState <: AbstractControlState
    is_running::Bool
    count::Int

    function ControlState()
        is_running = false
        count = 0
        new(is_running, count)
    end
end

@enum ControlSignal begin
    START
    STOP
    INCREMENT
end

function Boid.decode_control_signal(::Type{ControlState}, bytes::Vector{UInt8})
    return reinterpret(ControlSignal, bytes)[1]
end

function Boid.get_exception_signal(::Type{ControlState})
    return "FAILED"
end

function Boid.process_control_signal!(signal, state::ControlState)
    if signal == START
        state.is_running = true
    elseif signal == STOP
        state.is_running = false
    elseif signal == INCREMENT
        state.count += 1
    else
        throw(ArgumentError("Unknown signal"))
    end

    return "SUCCESS"
end
