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

      * `url`: URL that OutputChannel publishes output data on

      * `socket`: ZMQ Socket for sending data
    =#
    data::AbstractChannelData
    url::String
    socket::Socket
end


"""
    OutputChannel(data_type::Type{<:AbstractChannelData}, url::String;
                 use_bind=false)

Construct an input channel that publishes data of type `data_type` to `url`.
When `use_bind` is true, the ZMQ Socket that messages are published to is
connected to `url` using the `bind()` method. Otherwise, the ZMQ Socket is
connected to `url` using the `connect()` method.
"""
function OutputChannel(data_type::Type{<:AbstractChannelData},
                       url::String;
                       use_bind=true)

    # Create data storage
    data = data_type()

    # Create Socket to publish output data
    socket = Socket(PUB)

    # Connect socket to URL
    if use_bind
        bind(socket, url)
    else
        connect(socket, url)
    end

    # Return new ControlUnit
    OutputChannel(data, url, socket)
end

# --- Method definitions

"""
    TODO
"""
function publish(channel::OutputChannel, data)
    # Encode data
    bytes = encode_data(typeof(channel.data), data)

    # Send outgoing data
    send(channel.socket, bytes)

    # Update most recent data sent
    set_current_value!(channel.data, data)
end

"""
    TODO
"""
get_current_value(channel::OutputChannel) =
    get_current_value(channel.data)
