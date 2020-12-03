"""
Unit tests for InputChannel type.

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the XYZ package. It is subject to
the license terms in the LICENSE file found in the top-level directory of
this distribution. No part of the XYZ package, including this file, may be
copied, modified, propagated, or distributed except according to the terms
contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Imports

# Standard library
using Test

# External packages
using ZMQ

# Boid.jl package
using Boid

# --- Test fixtures

# Concrete subtype of AbstractChannelData
include("fixtures/TestChannelData.jl")

# Constants
input_url = construct_ipc_url(".", "input-channel-test.zmq")
input_ipc_path = input_url[7:end]

# --- Set up/tear down methods

function _tearDown()
    rm(input_ipc_path, force=true)
end

# --- Constructor tests

@testset "InputChannel: constructor" begin
    # --- Tests

    input_channel = InputChannel(TestChannelData, input_url, use_bind=false)

    @test input_channel.data isa TestChannelData
    @test input_channel.url == input_url
    @test input_channel.socket isa Socket

    # --- Clean up
    _tearDown()
end

@testset "InputChannel: listen()" begin
    # --- Preparations

    # Create InputChannel
    input_channel = InputChannel(TestChannelData, input_url, use_bind=false)

    # Create ZMQ Socket to send data on
    socket = Socket(PUB)
    bind(socket, input_url)

    # Get initial value of input channel data
    initial_channel_value = get_last_value(input_channel)

    # --- Tests

    # Start listnening for input data
    @async listen(input_channel)
    while !input_channel.state.is_listening
        sleep(0.1)
    end
    @test input_channel.state.is_listening

    # Send value
    data_sent = rand()
    while data_sent == initial_channel_value
        data_sent = rand()
    end
    send(socket, encode_data(TestChannelData, data_sent))

    while input_channel.state.is_listening
        sleep(0.1)
    end
    @test get_last_value(input_channel) == data_sent
    @test !input_channel.state.is_listening

    # --- Clean up
    _tearDown()
end
