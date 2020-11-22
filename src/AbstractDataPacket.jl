"""
AbstractDataPacket.jl defines the AbstractDataPacket type and methods

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

export AbstractDataPacket

# ------ Functions

export encode_packet, decode_packet

# --- Type definitions

"""
    AbstractDataPacket

Supertype for data packet types. Concrete subtypes should

* possess a default constructor with no arguments and

* be mutable or contain mutable fields so that they can be modified to
  represent the most recent data contained in an InputChannel or
  OutputChannel.

Interface
=========

    encode_packet(data)::Vector{UInt8}

    decode_packet(::Type{<:AbstractDataPacket}, bytes::Vector{UInt8})
"""
abstract type AbstractDataPacket end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    encode_packet(data)::Vector{UInt8}

Convert data to Vector{UInt8}.
"""
encode_packet(data)::Vector{UInt8} = nothing

"""
    decode_packet(::Type{<:AbstractDataPacket}, bytes::Vector{UInt8})

Convert `bytes` to data.
"""
decode_packet(::Type{<:AbstractDataPacket}, bytes::Vector{UInt8}) = nothing
