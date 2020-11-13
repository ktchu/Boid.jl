"""
The TypeTemplate.jl module demonstrates a Julia module.

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

export Node

# ------ Functions

export say_hello, add_one

# --- Type definition

struct Node
    #=
      Fields
      ------
      * `id`: node ID
      * `connections`: Dict
    =#
    id::Int
    connections::Dict{Int, Int}
end
