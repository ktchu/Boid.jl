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

export listen, loop_listen, is_listening
export get_value

# --- Type definitions

using ZMQ
include("InputChannelState.jl")

"""
    struct InputChannel

Component that listens for and decodes input data. The `data` field stores the
data most recently received by the channel.
"""
struct InputChannel
    #=
      Fields
      ------
      * `state`: current state of channel

      * `data`: most recently received data

      * `url`: URL that InputChannel listens for input data on

      * `socket`: ZMQ Socket for receiving data
    =#
    state::InputChannelState
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
    # Create channel state
    state = InputChannelState()

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

    # Return new InputChannel
    InputChannel(state, data, url, socket)
end

# --- Method definitions

"""
    listen(channel::InputChannel)

Listen for a single incoming message on `channel`.

Notes
-----
* To listen for a message without blocking, call `listen()` within an
  asynchronous Task.
"""
function listen(channel::InputChannel)
    # Preparations
    message = nothing  # initialized so that it is available outside of Task

    # Listen for incoming message
    task = @task message = recv(channel.socket, Vector{UInt8})
    schedule(task)

    # Update state
    channel.state.is_listening = true

    # Wait for message to arrive
    wait(task)

    # Update channel data
    set_data!(channel.data, message, decode=true)

    # Update state
    channel.state.is_listening = false
end

"""
    loop_listen(channel::InputChannel)

Start loop to continuously and asynchronously listen for incoming messages on
`channel`.
"""
function loop_listen(channel::InputChannel)
    @async begin
        while true
            listen(channel)
        end
    end
end

"""
    is_listening(channel::InputChannel)

Return true if `channel` is in 'listening' state; return false otherwise.
"""
is_listening(channel::InputChannel) = channel.state.is_listening

"""
    get_value(channel::InputChannel)

Return the most recent data value received by `channel`.
"""
get_value(channel::InputChannel) = get_data(channel.data)
