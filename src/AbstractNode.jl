"""
AbstractNode.jl defines the AbstractNode type and methods

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

export AbstractNode

# ------ Functions

export get_output_type

# --- Type definitions

"""
    AbstractNode

Supertype for node types.

Interface
=========

    get_output_type(node::AbstractNode)
"""
abstract type AbstractNode end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    get_output_type(node::AbstractNode)

Return the output type of `node`.
"""
get_output_type(node::AbstractNode) = nothing
