"""
AbstractChannelData.jl defines the AbstractChannelData type and methods

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

export AbstractChannelData

# ------ Functions

export get_data, set_data!
export encode_value, decode_value

# --- Type definitions

"""
    AbstractChannelData

Supertype for channel data types. Concrete subtypes should

* possess a default constructor with no arguments and

* be mutable or contain mutable fields so that they can be modified to
  represent the most recent data sent or received by a data channel.

Interface
=========

    get_data(channel_data::AbstractChannelData)

    set_data!(channel_data::AbstractChannelData, value)

    encode_value(::Type{<:AbstractChannelData}, data)::Vector{UInt8}

    decode_value(::Type{<:AbstractChannelData}, bytes::Vector{UInt8})
"""
abstract type AbstractChannelData end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    get_data(channel_data::AbstractChannelData; encode::Bool=false)

Return the data value stored by `channel_data`. When `encode` is true, the data
value is encoded as a byte vector using the `encode_value()` function before
being returned. When `encode` is false, the data value is returned directly.
"""
get_data(channel_data::AbstractChannelData; encode::Bool=false) = nothing

"""
    set_data!(channel_data::AbstractChannelData, value; decode::Bool=false)

Set the data stored by `channel_data` to `value`. When `decode` is true,
`value` is intepreted as a byte vector and decoded using the `decode_value()`
function before being stored. When `decode` is false, `value` is stored as-is.
"""
set_data!(channel_data::AbstractChannelData, value; decode::Bool=false) =
    nothing

"""
    encode_value(value)::Vector{UInt8}

Encode `value` as a byte vector.
"""
encode_value(::Type{<:AbstractChannelData}, value)::Vector{UInt8} = nothing

"""
    decode_value(::Type{<:AbstractChannelData}, bytes::Vector{UInt8})

Convert `bytes` to a value.
"""
decode_value(::Type{<:AbstractChannelData}, bytes::Vector{UInt8}) = nothing
