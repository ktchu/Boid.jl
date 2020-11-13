"""
The AbstractControlState.jl module defines the AbstractControlState type and
methods

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

export AbstractControlState

# ------ Functions

export process_control_signal

# --- Type definitions

"""
    AbstractControlState

Supertype for control state types.

Interface
=========

    process_control_signal(state::AbstractControlState, signal::Vector{UInt8})
"""
abstract type AbstractControlState end
