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
    data::Float64

    # Default constructor
    TestChannelData() = new()
end

# --- Method definitions

Boid.get_type(channel_data::TestChannelData) = typeof(channel_data.data)

Boid.get_data(channel_data::TestChannelData; encode::Bool=false) =
    encode ?
        encode_value(TestChannelData, channel_data.data) :
        channel_data.data

function Boid.set_data!(channel_data::TestChannelData, value;
                        decode::Bool=false)
    if decode
        channel_data.data = decode_value(TestChannelData, value)
    else
        channel_data.data = value
    end
end

function Boid.encode_value(::Type{TestChannelData}, data)::Vector{UInt8}
    packed_data = IOBuffer()
    serialize(packed_data, data)
    return take!(packed_data)
end

function Boid.decode_value(::Type{TestChannelData}, bytes::Vector{UInt8})
    packed_data = IOBuffer()
    write(packed_data, bytes)
    return deserialize(seekstart(packed_data))
end
