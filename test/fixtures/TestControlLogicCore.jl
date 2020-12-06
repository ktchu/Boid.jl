"""
TestControlLogicCore.jl defines the TestControlLogicCore type and methods

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Imports

using Boid: AbstractControlLogicCore

# --- Type definitions

mutable struct TestControlLogicCore <: AbstractControlLogicCore
    #=
      Control state
    =#
    is_running::Bool
    count::Int

    # Default constructor
    function TestControlLogicCore()
        is_running = false
        count = 0
        new(is_running, count)
    end
end

@enum TestControlSignal begin
    START
    STOP
    INCREMENT
end

# --- Method definitions

function Boid.set_running!(logic_core::TestControlLogicCore)
    logic_core.is_running = true
end

Boid.is_running(logic_core::TestControlLogicCore) = logic_core.is_running

Boid.wait_for_input_ready(logic_core::TestControlLogicCore,
                          input_channels::Vector{InputChannel}) = nothing

function Boid.decode_control_signal(::Type{TestControlLogicCore},
                                    bytes::Vector{UInt8})
    return reinterpret(TestControlSignal, bytes)[1]
end

function Boid.get_exception_signal(::Type{TestControlLogicCore})
    return "FAILED"
end

function Boid.process_control_signal!(logic_core::TestControlLogicCore, signal)
    if signal == START
        logic_core.is_running = true
    elseif signal == STOP
        logic_core.is_running = false
    elseif signal == INCREMENT
        logic_core.count += 1
    else
        throw(ArgumentError("Unknown signal"))
    end

    return "SUCCESS"
end
