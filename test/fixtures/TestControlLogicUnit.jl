"""
TestControlLogicUnit.jl defines the TestControlLogicUnit type and methods

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Imports

using Boid: AbstractControlLogicUnit

# --- Type definitions

mutable struct TestControlLogicUnit <: AbstractControlLogicUnit
    #=
      Control state
    =#
    is_running::Bool
    count::Int

    # Default constructor
    function TestControlLogicUnit()
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

function Boid.decode_control_signal(::Type{TestControlLogicUnit},
                                    bytes::Vector{UInt8})
    return reinterpret(TestControlSignal, bytes)[1]
end

function Boid.get_exception_signal(::Type{TestControlLogicUnit})
    return "FAILED"
end

function Boid.process_control_signal!(logic_unit::TestControlLogicUnit, signal)
    if signal == START
        logic_unit.is_running = true
    elseif signal == STOP
        logic_unit.is_running = false
    elseif signal == INCREMENT
        logic_unit.count += 1
    else
        throw(ArgumentError("Unknown signal"))
    end

    return "SUCCESS"
end
