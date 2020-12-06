"""
AbstractControlLogicCore.jl defines the AbstractControlLogicCore type and
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

export AbstractControlLogicCore

# ------ Functions

export decode_control_signal, process_control_signal!
export get_exception_signal
export set_running!, is_running
export wait_for_input_ready

# --- Type definitions

"""
    AbstractControlLogicCore

Supertype for control logic core types. In general, concrete subtypes should
be mutable when the control logic core maintains modifiable control state.

Interface
=========

    set_running!(logic_core::AbstractControlLogicCore)

    is_running(logic_core::AbstractControlLogicCore)

    wait_for_input_ready(logic_core::AbstractControlLogicCore,
                         input_channels::Vector{InputChannel})

    decode_control_signal(::Type{<:AbstractControlLogicCore},
                          bytes::Vector{UInt8})

    get_exception_signal(::Type{<:AbstractControlLogicCore})

    process_control_signal!(signal, logic_core::AbstractControlLogicCore)

Common Signals to Support
-------------------------
* Request for the output type. To support this signal, include the Node or
  OutputChannel as a field in the concrete subtype.
"""
abstract type AbstractControlLogicCore end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    set_running!(logic_core::AbstractControlLogicCore)

Put `logic_core` into running state.
"""
set_running!(logic_core::AbstractControlLogicCore) = nothing

"""
    is_running(logic_core::AbstractControlLogicCore)

Return true if the Node is running; return false otherwise.
"""
is_running(logic_core::AbstractControlLogicCore) = nothing

"""
    wait_for_input_ready(logic_core::AbstractControlLogicCore,
                         input_channels::Vector{InputChannel})

Wait for input channels to be ready for processing.
"""
wait_for_input_ready(logic_core::AbstractControlLogicCore,
                     input_channels::Vector{InputChannel}) = nothing

"""
    decode_control_signal(::Type{<:AbstractControlLogicCore},
                          bytes::Vector{UInt8})

Convert `bytes` to a signal that is understood by `process_control_signal()`.
"""
decode_control_signal(::Type{<:AbstractControlLogicCore}, bytes::Vector{UInt8}) =
    nothing

"""
    get_exception_signal(::Type{<:AbstractControlLogicCore})

Return the response to send when `process_control_signal()` fails.
"""
get_exception_signal(::Type{<:AbstractControlLogicCore}) = nothing

"""
    process_control_signal!(logic_core::AbstractControlLogicCore, signal)

Process the control `signal`, updating `logic_core` and returning a response as
appropriate.
"""
process_control_signal!(logic_core::AbstractControlLogicCore, signal) = nothing
