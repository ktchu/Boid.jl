"""
The OutputChannel.jl module defines the OutputChannel type and methods

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

export OutputChannel

# ------ Functions

export publish

# --- Type definitions

using ZMQ

"""
    struct OutputChannel

Component that encodes and publishes output data. The `data` field stores the
data most recently sent by the channel.
"""
struct OutputChannel
    #=
      Fields
      ------
      * `data`: most recently received data

      * `output_url`: URL that OutputChannel publishes output data on

      * `output_socket`: ZMQ Socket for sending data
    =#
    data::AbstractDataPacket
    output_url::String
    output_socket::Socket
end


"""
    OutputChannel(data_type::Type{<:AbstractDataPacket}, output_url::String;
                 use_bind=false)

Construct an input channel that publishes data of type `data_type` to
`output_url`.

When `use_bind` is true, the ZMQ Socket that messages are published to is
connected to `output_url` using the `bind()` method. Otherwise, the ZMQ Socket
is connected to `output_url` using the `connect()` method.
"""
function OutputChannel(data_type::Type{<:AbstractDataPacket},
                       output_url::String;
                       use_bind=true)

    # Create data storage
    data = data_type()

    # Create Socket to publish output data
    output_socket = Socket(PUB)

    # Connect socket to URL
    if use_bind
        bind(output_socket, output_url)
    else
        connect(output_socket, output_url)
    end

    # Return new ControlUnit
    OutputChannel(data, output_url, output_socket)
end

# --- Method definitions

function publish(output_channel::OutputChannel)
    # Encode data
    encoded_data = encode_data(output_channel.data)

    # Send output data
    send(output_channel.output_socket, encoded_data)
end
