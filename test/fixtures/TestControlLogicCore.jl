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

using Boid: Boid
using Boid: AbstractControlLogicCore, InputChannel

# --- Type definitions

mutable struct TestControlLogicCore <: AbstractControlLogicCore
    #=
      Control state
    =#
    count::Int

    # Default constructor
    function TestControlLogicCore()
        count = 0
        new(count)
    end
end

@enum TestControlSignal begin
    INCREMENT
end

TEST_CONTROL_SIGNALS = instances(TestControlSignal)

# --- Method definitions

Boid.wait_for_input_ready(logic_core::TestControlLogicCore,
                          input_channels::Vector{InputChannel}) = nothing

function Boid.decode_control_signal(::Type{TestControlLogicCore},
                                    bytes::Vector{UInt8})

    signal = reinterpret(TestControlSignal, bytes)[1]

    if !(signal in TEST_CONTROL_SIGNALS)
        throw(ArgumentError("Unknown signal $(Int(signal))"))
    end

    return signal
end

function Boid.process_control_signal!(logic_core::TestControlLogicCore, signal)
    if signal == INCREMENT
        logic_core.count += 1
    else
        throw(ArgumentError("Unknown signal $(Int(signal))"))
    end

    return Boid.SUCCESS
end
