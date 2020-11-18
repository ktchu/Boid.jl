"""
The AbstractInputData.jl module defines the AbstractInputData type and methods

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

export AbstractInputData

# ------ Functions

export decode_input_data

# --- Type definitions

"""
    AbstractInputData

Supertype for input data types. Concrete subtypes should

* be mutable or contain mutable fields so that they can be modified to
  represent the input received by the InputChannels and

* possess a default constructor with no arguments.

Interface
=========

    decode_input_data(::Type{<:AbstractInputData}, bytes::Vector{UInt8})
"""
abstract type AbstractInputData end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    decode_input_data(::Type{<:AbstractInputData}, bytes::Vector{UInt8})

Convert `bytes` to input data.
"""
decode_input_data(::Type{<:AbstractInputData}, bytes::Vector{UInt8}) = nothing
