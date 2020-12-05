"""
AbstractNodeData.jl defines the AbstractNodeData type and methods

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

export AbstractNodeData

# ------ Functions

# --- Type definitions

"""
    AbstractNodeData

Supertype for node data types. Concrete subtypes should

* possess a default constructor with no arguments and

* be mutable or contain mutable fields so that they can be modified as the
  node processes input.
"""
abstract type AbstractNodeData end
