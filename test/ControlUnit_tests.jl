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

# ------ Constants

control_url = construct_ipc_url(".", "control-unit-test.zmq")
ipc_path = control_url[7:end]

# ------ ControlState

mutable struct ControlState <: AbstractControlState
    is_running::Bool
    count::Int

    function ControlState()
        is_running = false
        count = 0
        new(is_running, count)
    end
end

@enum ControlSignal begin
    START
    STOP
    INCREMENT
end

function Boid.decode_control_signal(::Type{ControlState}, bytes::Vector{UInt8})
    return reinterpret(ControlSignal, bytes)[1]
end

function Boid.get_exception_signal(::Type{ControlState})
    return "FAILED"
end

function Boid.process_control_signal!(signal, state::ControlState)
    if signal == START
        state.is_running = true
    elseif signal == STOP
        state.is_running = false
    elseif signal == INCREMENT
        state.count += 1
    else
        throw(ArgumentError("Unknown signal"))
    end

    return "SUCCESS"
end

# --- Set up/tear down methods

function _tearDown()
    rm(ipc_path, force=true)
end

# --- Constructor tests

@testset "ControlUnit: constructor" begin
    # --- Preparations

    state = ControlState()

    # --- Tests

    control_unit = ControlUnit(state, control_url)

    @test control_unit.state isa ControlState
    @test control_unit.state !== state
    @test control_unit.control_url == control_url
    @test control_unit.control_channel isa Socket

    # --- Clean up
    _tearDown()
end

@testset "ControlUnit: run()" begin
    # --- Preparations

    state = ControlState()
    control_unit = ControlUnit(state, control_url)

    # --- Tests

    # Start run()
    @async run(control_unit)

    # Sent START signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, START)
    response = recv(socket, String)
    @test control_unit.state.is_running == true
    @test control_unit.state.count == 0
    @test response == "SUCCESS"

    # Sent STOP signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, STOP)
    response = recv(socket, String)
    @test control_unit.state.is_running == false
    @test control_unit.state.count == 0
    @test response == "SUCCESS"

    # Sent INCREMENT signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, INCREMENT)
    response = recv(socket, String)
    @test control_unit.state.is_running == false
    @test control_unit.state.count == 1
    @test response == "SUCCESS"

    # Sent unknown signal
    socket = Socket(REQ)
    connect(socket, control_url)
    send(socket, 100)
    response = recv(socket, String)
    @test response == get_exception_signal(ControlState)

    # --- Clean up
    _tearDown()
end
