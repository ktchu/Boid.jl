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

export decode_control_signal
export get_exception_signal
export process_control_signal

# --- Type definitions

"""
    AbstractControlState

Supertype for control state types. In general, concrete subtypes should be
mutable so that they can be modified as the control state changes.

Interface
=========

    decode_control_signal(::Type{<:AbstractControlState}, bytes::Vector{UInt8})

    get_exception_signal(::Type{<:AbstractControlState})

    process_control_signal!(signal, state::AbstractControlState)
"""
abstract type AbstractControlState end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    decode_control_signal(bytes::Vector{UInt8}, ::Type{<:AbstractControlState})

Convert `bytes` to a signal that is understood by `process_control_signal()`.
"""
decode_control_signal(::Type{<:AbstractControlState}, bytes::Vector{UInt8}) =
    nothing

"""
    get_exception_signal(::Type{<:AbstractControlState})

Return the response to send when `process_control_signal()` fails.
"""
get_exception_signal(::Type{<:AbstractControlState}) = nothing

"""
    process_control_signal(signal, state::AbstractControlState)

Process the control `signal`, updating `state` and returning a response as
appropriate.
"""
process_control_signal!(signal, state::AbstractControlState) = nothing
