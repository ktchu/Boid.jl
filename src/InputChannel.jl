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

export listen

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

      * `input_url`: URL that InputChannel listens for input data on

      * `input_socket`: ZMQ Socket for receiving data
    =#
    data::AbstractDataPacket
    input_url::String
    input_socket::Socket

    # TODO: Remove
    # Temporary constructor
    InputChannel() = new()

    """
    TODO
    """
    function InputChannel(data_type::Type{<:AbstractDataPacket},
                          input_url::String;
                          use_bind=false)

        # Create data storage
        data = data_type()

        # Create Socket to listen for input data
        input_socket = Socket(SUB)
        subscribe(input_socket, "")

        # Connect socket to URL
        if use_bind
            bind(input_socket, input_url)
        else
            connect(input_socket, input_url)
        end

        # Return new ControlUnit
        new(data, input_url, input_socket)
    end
end

# --- Method definitions

function listen(input_channel::InputChannel)
    # Wait for input data
    message = recv(input_channel.input_socket, Vector{UInt8})

    # Decode data
    decode_input_data(typeof(input_channel.data), message)

    # Restart input_channel
    @async listen(input_channel)
end
