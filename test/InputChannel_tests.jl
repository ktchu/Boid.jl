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
    initial_channel_value = get_current_value(input_channel)

    # Initialize message received so that it is available outside of the
    # tasks.
    message_received = nothing

    # --- Tests

    # Start listnening for input data
    # task = @task message_received = listen(input_channel)
    # schedule(task)
    # sleep(0.1)  # give task time to start

    # Send value
    data = rand()
    while data == initial_channel_value
        data = rand()
    end
    message_sent = encode_data(TestChannelData, data)
    send(socket, message_sent)

    # wait(task)

    # --- Clean up
    _tearDown()
end

@testset "InputChannel: process_message()" begin
    # --- Preparations

    # Create InputChannel
    input_channel = InputChannel(TestChannelData, input_url, use_bind=false)

    # Get initial value of input channel data
    initial_channel_value = get_current_value(input_channel)

    # --- Tests

    # Process data value
    data = rand()
    while data == initial_channel_value
        data = rand()
    end
    message = encode_data(TestChannelData, data)
    process_message(input_channel, message)
    @test get_current_value(input_channel) == data

    # Process another data value
    initial_channel_value = data
    data = rand()
    while data == initial_channel_value
        data = rand()
    end
    message = encode_data(TestChannelData, data)
    process_message(input_channel, message)
    @test get_current_value(input_channel) == data

    # --- Clean up
    _tearDown()
end
