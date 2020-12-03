"""
The InputChannel.jl module defines the InputChannel type and methods

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

export InputChannel

# ------ Functions

export listen, process_message

# --- Type definitions

using ZMQ

"""
    struct InputChannel

Component that listens for and decodes input data. The `data` field stores the
data most recently received by the channel.
"""
struct InputChannel
    #=
      Fields
      ------
      * `data`: most recently received data

      * `url`: URL that InputChannel listens for input data on

      * `socket`: ZMQ Socket for receiving data
    =#
    data::AbstractChannelData
    url::String
    socket::Socket
end


"""
    InputChannel(data_type::Type{<:AbstractChannelData}, url::String;
                 use_bind=false)

Construct an input channel that listens for input published to `url` and stores
data of type `data_type`.

When `use_bind` is true, the ZMQ Socket that listens for messages is connected
to `url` using the `bind()` method. Otherwise, the ZMQ Socket is connected to
`url` using the `connect()` method.
"""
function InputChannel(data_type::Type{<:AbstractChannelData},
                      url::String;
                      use_bind=false)

    # Create data storage
    data = data_type()

    # Create Socket to listen for input data
    socket = Socket(SUB)
    subscribe(socket, "")

    # Connect socket to URL
    if use_bind
        bind(socket, url)
    else
        connect(socket, url)
    end

    # Return new ControlUnit
    InputChannel(data, url, socket)
end

# --- Method definitions

"""
    get_current_value(channel::InputChannel)

Return most recent data value received by `channel`.
"""
get_current_value(channel::InputChannel) = get_current_value(channel.data)

"""
    start(channel::InputChannel)

Start listen-process loop for `channel`.
"""
function start(channel::InputChannel)
    while true
        message = listen(channel)
        process_message(channel, message)
    end
end

"""
    listen(channel::InputChannel)

Listen for the next message on `channel`.
"""
listen(channel::InputChannel) = recv(channel.socket, Vector{UInt8})

"""
    process_message(channel::InputChannel, message)

Decoded `message` and decoded value to update `channel` data.
"""
function process_message(channel::InputChannel, message)
    # Decode data
    data = decode_data(typeof(channel.data), message)

    # Update most recent data received
    set_current_value!(channel.data, data)
end
