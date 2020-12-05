"""
Unit tests for ControlUnit type.

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

# Concrete subtype of AbstractControlState
include("fixtures/TestControlState.jl")

# Constants
control_url = construct_ipc_url(".", "control-unit-test.zmq")
control_ipc_path = control_url[7:end]

# --- Set up/tear down methods

function _tearDown()
    rm(control_ipc_path, force=true)
end

# --- Tests

@testset "ControlUnit: constructor" begin
    # --- Preparations

    state = TestControlState()

    # --- Tests

    # copy_state == true
    control_unit = ControlUnit(state, control_url)

    @test control_unit.state isa TestControlState
    @test control_unit.state !== state
    @test control_unit.url == control_url
    @test control_unit.socket isa Socket

    # copy_state == false
    control_unit = ControlUnit(state, control_url, copy_state=false)

    @test control_unit.state isa TestControlState
    @test control_unit.state === state
    @test control_unit.url == control_url
    @test control_unit.socket isa Socket

    # --- Clean up

    _tearDown()
end

@testset "ControlUnit: run()" begin
    # --- Preparations

    state = TestControlState()
    control_unit = ControlUnit(state, control_url)

    # --- Tests

    # Start run()
    @async run(control_unit)

    # Send START signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, START)
    response = recv(socket, String)
    @test control_unit.state.is_running == true
    @test control_unit.state.count == 0
    @test response == "SUCCESS"

    # Send STOP signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, STOP)
    response = recv(socket, String)
    @test control_unit.state.is_running == false
    @test control_unit.state.count == 0
    @test response == "SUCCESS"

    # Send INCREMENT signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, INCREMENT)
    response = recv(socket, String)
    @test control_unit.state.is_running == false
    @test control_unit.state.count == 1
    @test response == "SUCCESS"

    # Send unknown signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, 100)
    response = recv(socket, String)
    @test response == get_exception_signal(TestControlState)

    # --- Clean up

    _tearDown()
end
