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

export wait_for_input_ready
export decode_control_signal, process_control_signal!

# --- Type definitions

"""
    AbstractControlLogicCore

Supertype for control logic core types.

Interface
=========

    wait_for_input_ready(logic_core::AbstractControlLogicCore,
                         input_channels::Vector{InputChannel})

    decode_control_signal(::Type{<:AbstractControlLogicCore},
                          bytes::Vector{UInt8})

    process_control_signal!(signal, logic_core::AbstractControlLogicCore)

    get_state(logic_core::AbstractControlLogicCore)

    set_state!(logic_core::AbstractControlLogicCore, state::Dict)

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
Throw an ArgumentError if `bytes` does not convert to a valid signal.
"""
decode_control_signal(::Type{<:AbstractControlLogicCore},
                      bytes::Vector{UInt8}) = nothing

"""
    process_control_signal!(logic_core::AbstractControlLogicCore, signal)

Process the control `signal` updating the data fields of `logic_core`, if
necesasry. Return an appropriate status response.
"""
process_control_signal!(logic_core::AbstractControlLogicCore, signal) = nothing

"""
    get_state(logic_core::AbstractControlLogicCore)

Return a Dict containing sufficient information to reconstruct the operational
state of `logic_core`.
"""
get_state(logic_core::AbstractControlLogicCore) = nothing

"""
    set_state!(logic_core::AbstractControlLogicCore, state::Dict)

Set the operational state of `logic_core` using values from `state`.
"""
set_state!(logic_core::AbstractControlLogicCore, state::Dict) = nothing
