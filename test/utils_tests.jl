"""
Unit tests for methods defined in utils.jl.

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
using ZMQ: Socket

# Boid.jl package
using Boid

# --- Test fixtures

# --- Constructor tests

@testset "utils.jl: construct_ipc_url()" begin
    # --- ipc_dir does not start with "ipc://"

    # ipc_dir is a relative path
    ipc_dir = "path/to/ipc/dir"
    ipc_name = "ipc-name"
    ipc_url = construct_ipc_url(ipc_dir, ipc_name)
    @test ipc_url == "ipc://path/to/ipc/dir/ipc-name"

    # ipc_dir is an absolute path
    ipc_dir = "/path/to/ipc/dir"
    ipc_name = "ipc-name"
    ipc_url = construct_ipc_url(ipc_dir, ipc_name)
    @test ipc_url == "ipc:///path/to/ipc/dir/ipc-name"

    # --- ipc_dir starts with "ipc://"

    # ipc_dir is a relative path
    ipc_dir = "ipc://path/to/ipc/dir"
    ipc_name = "ipc-name"
    ipc_url = construct_ipc_url(ipc_dir, ipc_name)
    @test ipc_url == "ipc://path/to/ipc/dir/ipc-name"

    # ipc_dir is an absolute path
    ipc_dir = "ipc:///path/to/ipc/dir"
    ipc_name = "ipc-name"
    ipc_url = construct_ipc_url(ipc_dir, ipc_name)
    @test ipc_url == "ipc:///path/to/ipc/dir/ipc-name"
end
