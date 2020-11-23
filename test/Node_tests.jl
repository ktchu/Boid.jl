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
include("fixtures/TestControlState.jl")
include("fixtures/TestProcessingCore.jl")

# Constants
control_url = construct_ipc_url(".", "control-unit-test.zmq")
control_ipc_path = control_url[7:end]

output_url = construct_ipc_url(".", "output-unit-test.zmq")
output_ipc_path = output_url[7:end]

input_urls = Vector{String}()
input_ipc_paths = Vector{String}()
for i in 1:3
    input_url = construct_ipc_url(".", "output-unit-test-$i.zmq")
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

# --- Constructor tests

@testset "Node: constructor" begin
    # --- Preparations

    id = "node-1"

    processing_core = TestProcessingCore()

    control_unit_params = Dict(
        "state"=>TestControlState(),
        "url"=>control_url,
        "copy_state"=>false)

    output_channel_params = Dict(
        "url"=>output_url,
        "data_type"=>TestChannelData)

    input_channel_params = Vector{Dict}()
    for input_url in input_urls
        push!(input_channel_params,
              Dict(
                "url"=>input_url,
                "data_type"=>TestChannelData))
    end

    # --- Tests

    node = Node(id, processing_core,
                control_unit_params,
                output_channel_params,
                input_channel_params)

    # --- Clean up
    _tearDown()
end
