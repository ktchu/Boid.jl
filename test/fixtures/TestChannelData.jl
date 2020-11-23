"""
TestChannelData.jl defines the TestChannelData types and methods

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Imports

using Boid: Node

# --- TestChannelData

mutable struct TestChannelData <: AbstractChannelData
    node::Node
    float_field::Float64
    int_field::Int

    TestChannelData() = new()
end
