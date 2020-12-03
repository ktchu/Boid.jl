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

using Serialization: serialize, deserialize
using Boid: AbstractChannelData

# --- Type definitions

mutable struct TestChannelData <: AbstractChannelData
    node::Node
    current_value::Float64

    # Default constructor
    TestChannelData() = new()
end

# --- Method definitions

Boid.get_current_value(channel_data::AbstractChannelData) =
    channel_data.current_value

function Boid.set_current_value!(channel_data::AbstractChannelData, value)
    channel_data.current_value = value
end

function Boid.encode_data(::Type{<:AbstractChannelData}, data)::Vector{UInt8}
    packed_data = IOBuffer()
    serialize(packed_data, data)
    return take!(packed_data)
end

function Boid.decode_data(::Type{<:AbstractChannelData}, bytes::Vector{UInt8})
    packed_data = IOBuffer()
    write(packed_data, bytes)
    return deserialize(seekstart(packed_data))
end
