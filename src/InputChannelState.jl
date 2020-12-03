"""
The InputChannelState.jl module defines the InputChannelState type and methods

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

export InputChannelState

# --- Type definitions

"""
    mutable struct InputChannelState

State of input channel.
"""
mutable struct InputChannelState
    #=
      Fields
      ------
      * `is_listening`: flag indicating whether the channel is currently
                        listening
    =#
    is_listening::Bool
end

"""
    InputChannelState()

Construct an InputChannelState instance initialized with default values.
"""
function InputChannelState()
    # Initialize state
    is_listening = false

    # Return new InputChannelState
    InputChannelState(is_listening)
end
