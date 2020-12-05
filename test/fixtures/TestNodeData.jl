"""
TestNodeData.jl defines the TestNodeData types and methods

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Imports

using Boid: AbstractNodeData

# --- Type definitions

mutable struct TestNodeData <: AbstractNodeData
    field_1::Float64
    field_2::Int

    # Default constructor
    TestNodeData() = new()
end
