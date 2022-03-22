"""
AbstractProcessingCore.jl defines the AbstractProcessingCore type and interface

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

export AbstractProcessingCore

# ------ Functions

export process_data!

# --- Type definitions

"""
    AbstractProcessingCore

Supertype for all processing core types. Concrete subtypes should be defined
with any data required to perform its processing functions. In general,
concrete subtypes should be mutable when the process core maintains
_modifiable_ data.

Interface
=========

Functions
---------
* TODO
"""
abstract type AbstractProcessingCore end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    process_data!(processing_core::AbstractProcessingCore, data::Vector)

Return the result of using `processing_core` to process `data`.
"""
process_data!(processing_core::AbstractProcessingCore, data::Vector) = nothing
