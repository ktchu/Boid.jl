"""
TestProcessingCore.jl defines the TestProcessingCore types and methods

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
using Boid: AbstractProcessingCore

# --- Type definitions

mutable struct TestProcessingCore <: AbstractProcessingCore
    # Data
    field_1::Float64
    field_2::Float64

    # Default constructor
    TestProcessingCore() = new(0.1, 1)
end

# --- Method definitions

function Boid.process_data!(processing_core::TestProcessingCore, data::Vector)
    processing_core.field_1 = data[1]
    processing_core.field_2 = data[2]
    return processing_core.field_1 + processing_core.field_2
end
