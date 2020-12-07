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

# Concrete subtype of AbstractControlLogicCore
include("fixtures/TestControlLogicCore.jl")

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

    logic_core = TestControlLogicCore()

    # --- Tests

    # copy_logic_core == true
    control_unit = ControlUnit(logic_core, control_url)

    @test control_unit.logic_core isa TestControlLogicCore
    @test control_unit.logic_core !== logic_core
    @test control_unit.url == control_url
    @test control_unit.socket isa Socket

    # copy_logic_core == false
    control_unit = ControlUnit(logic_core, control_url, copy_logic_core=false)

    @test control_unit.logic_core isa TestControlLogicCore
    @test control_unit.logic_core === logic_core
    @test control_unit.url == control_url
    @test control_unit.socket isa Socket

    # --- Clean up

    _tearDown()
end

@testset "ControlUnit: run!()" begin
    # --- Preparations

    logic_core = TestControlLogicCore()
    control_unit = ControlUnit(logic_core, control_url)

    # --- Tests

    # Start control signal processing
    run!(control_unit)

    # Send Boid.START signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, Boid.START)
    response = recv(socket, ControlUnitResponse)
    @test is_running(control_unit)
    @test !is_terminated(control_unit)
    @test control_unit.logic_core.count == 0
    @test response == Boid.SUCCESS

    # Send INCREMENT signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, INCREMENT)
    response = recv(socket, ControlUnitResponse)
    @test is_running(control_unit)
    @test !is_terminated(control_unit)
    @test control_unit.logic_core.count == 1
    @test response == Boid.SUCCESS

    # Send unknown signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, 100)
    response = recv(socket, ControlUnitResponse)
    @test response == Boid.UNKNOWN_SIGNAL

    # Send Boid.STOP signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, Boid.STOP)
    response = recv(socket, ControlUnitResponse)
    @test !is_running(control_unit)
    @test !is_terminated(control_unit)
    @test control_unit.logic_core.count == 1
    @test response == Boid.SUCCESS

    # Send Boid.TERMINATED signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, Boid.TERMINATE)
    response = recv(socket, ControlUnitResponse)
    @test !is_running(control_unit)
    @test is_terminated(control_unit)
    @test response == Boid.SUCCESS

    # --- Clean up

    _tearDown()
end

@testset "ControlUnit: process_control_signal!()" begin
    @test_skip 1
end

@testset "ControlUnit: is_running()" begin
    @test_skip 1
end

@testset "ControlUnit: is_terminated()" begin
    @test_skip 1
end

@testset "ControlUnit: wait_for_input_ready()" begin
    @test_skip 1
end
