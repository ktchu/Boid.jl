"""
AbstractControlLogicUnit.jl defines the AbstractControlLogicUnit type and
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

export AbstractControlLogicUnit

# ------ Functions

export decode_control_signal
export get_exception_signal
export process_control_signal

# --- Type definitions

"""
    AbstractControlLogicUnit

Supertype for control logic unit types. In general, concrete subtypes should
be mutable when the control logic unit maintains _modifiable_ control state.

Interface
=========

    decode_control_signal(::Type{<:AbstractControlLogicUnit},
                          bytes::Vector{UInt8})

    get_exception_signal(::Type{<:AbstractControlLogicUnit})

    process_control_signal!(signal, logic_unit::AbstractControlLogicUnit)

Common Signals to Support
-------------------------
* Request for the output type. To support this signal, include the Node or
  OutputChannel as a field in the concrete subtype.
"""
abstract type AbstractControlLogicUnit end

# --- Method definitions
#
# Note: the following method definitions are no-op place holders to provide
#       a central location for docstrings.

"""
    decode_control_signal(::Type{<:AbstractControlLogicUnit},
                          bytes::Vector{UInt8})

Convert `bytes` to a signal that is understood by `process_control_signal()`.
"""
decode_control_signal(::Type{<:AbstractControlLogicUnit}, bytes::Vector{UInt8}) =
    nothing

"""
    get_exception_signal(::Type{<:AbstractControlLogicUnit})

Return the response to send when `process_control_signal()` fails.
"""
get_exception_signal(::Type{<:AbstractControlLogicUnit}) = nothing

"""
    process_control_signal!(logic_unit::AbstractControlLogicUnit, signal)

Process the control `signal`, updating `logic_unit` and returning a response as
appropriate.
"""
process_control_signal!(logic_unit::AbstractControlLogicUnit, signal) = nothing
