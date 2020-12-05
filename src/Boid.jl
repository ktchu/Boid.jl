"""
The Boid.jl module defines types and functions to support autonomous,
distributed computing/processing.

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
module Boid

# Abstract Types
include("AbstractChannelData.jl")
include("AbstractControlLogicUnit.jl")
include("AbstractNodeData.jl")
include("AbstractProcessingCore.jl")

# Concrete Types
include("InputChannel.jl")
include("OutputChannel.jl")

include("ControlUnit.jl")

include("Node.jl")

# Methods
include("utils.jl")

end  # End of Boid.jl module
