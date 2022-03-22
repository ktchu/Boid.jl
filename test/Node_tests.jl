"""
Unit tests for Node type.

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

# Concrete subtypes of abstract types
include("fixtures/TestChannelData.jl")
include("fixtures/TestControlLogicCore.jl")
include("fixtures/TestProcessingCore.jl")

# Constants
control_url = construct_ipc_url(".", "control-unit-test.zmq")
control_ipc_path = control_url[7:end]

output_url = construct_ipc_url(".", "output-unit-test.zmq")
output_ipc_path = output_url[7:end]

input_urls = Vector{String}()
input_ipc_paths = Vector{String}()
for i in 1:3
    local input_url = construct_ipc_url(".", "output-unit-test-$i.zmq")
    push!(input_urls, input_url)
    push!(input_ipc_paths, input_url[7:end])
end

# --- Set up/tear down methods

function _tearDown()
    # Remove control IPC
    rm(control_ipc_path, force=true)

    # Remove output IPC
    rm(output_ipc_path, force=true)

    # Remove input IPCs
    for ipc_path in input_ipc_paths
        rm(ipc_path, force=true)
    end
end

# --- Tests

@testset "Node: constructor" begin
    # --- Preparations

    id = "node-1"

    processing_core = TestProcessingCore()

    control_unit_params = Dict(
        "logic_core"=>TestControlLogicCore(),
        "url"=>control_url,
        "copy_logic_core"=>false)

    output_channel_params = Dict(
        "url"=>output_url,
        "data_type"=>TestChannelData)

    input_channel_params = Vector{Dict}()
    local input_url
    for input_url in input_urls
        push!(input_channel_params,
              Dict(
                "url"=>input_url,
                "data_type"=>TestChannelData))
    end

    # --- Tests

    # ------- Normal usage

    node = Node(id, processing_core,
                control_unit_params,
                output_channel_params,
                input_channel_params)

    @test node.control_unit isa ControlUnit
    @test node.output_channel isa OutputChannel
    @test node.input_channels isa Vector{InputChannel}
    @test node.input_data isa Vector
    @test length(node.input_data) == length(input_channel_params)
    @test !is_running(node)

    # TODO: add tests

    # ------ Error cases

    # Invalid `control_unit_params`
    required_params = ["logic_core", "url"]
    for param in required_params
        invalid_control_unit_params = copy(control_unit_params)
        delete!(invalid_control_unit_params, param)
        expected_message =
            "`control_unit_params` is missing required parameter: `$param`"
        @test_throws(ArgumentError(expected_message),
                     Node(id, processing_core,
                          invalid_control_unit_params,
                          output_channel_params,
                          input_channel_params))
    end

    # Invalid `output_channel_params`
    required_params = ["data_type", "url"]
    for param in required_params
        invalid_output_channel_params = copy(output_channel_params)
        delete!(invalid_output_channel_params, param)
        expected_message =
            "`output_channel_params` is missing required parameter: `$param`"
        @test_throws(ArgumentError(expected_message),
                     Node(id, processing_core,
                          control_unit_params,
                          invalid_output_channel_params,
                          input_channel_params))
    end

    # Invalid `input_channel_params`
    required_params = ["data_type", "url"]
    for i in 1:length(input_channel_params)
        for param in required_params
            invalid_input_channel_params = deepcopy(input_channel_params)
            delete!(invalid_input_channel_params[i], param)
            expected_message =
            "`input_channel_params[$i]` is missing required parameter: `$param`"
            @test_throws(ArgumentError(expected_message),
                         Node(id, processing_core,
                              control_unit_params,
                              output_channel_params,
                              invalid_input_channel_params))
        end
    end

    # --- Clean up

    _tearDown()
end

@testset "Node: run()" begin

    # --- Preparations

    id = "node-1"

    processing_core = TestProcessingCore()

    control_unit_params = Dict(
        "logic_core"=>TestControlLogicCore(),
        "url"=>control_url,
        "copy_logic_core"=>false)

    output_channel_params = Dict(
        "url"=>output_url,
        "data_type"=>TestChannelData)

    input_channel_params = Vector{Dict}()
    local input_url
    for input_url in input_urls
        push!(input_channel_params,
              Dict(
                "url"=>input_url,
                "data_type"=>TestChannelData))
    end

    # Construct Node
    node = Node(id, processing_core,
                control_unit_params,
                output_channel_params,
                input_channel_params)

    # Construct control socket
    control_socket = Socket(REQ)
    connect(control_socket, control_url)

    # --- Tests
#=
    # Start node
    run_node_task = @task run(node)
    schedule(run_node_task)

#=
    # Wait for node to finish initializing
    while !is_running(node)
        sleep(0.1)
    end

    # Check that node is in 'running' state
    @test is_running(node)

    # Check that input channels are all in the 'listening' state
    for channel in node.input_channels
        while !is_listening(channel)
            sleep(0.1)
        end
        @test channel.state.is_listening
    end

    # Send STOP signal
    send(control_socket, STOP)
    response = recv(control_socket, String)
    @test response == "SUCCESS"

    # Wait for node to finish running
    wait(run_node_task)
    @test !is_running(node)

=#
    # --- Clean up
=#
    _tearDown()
end
