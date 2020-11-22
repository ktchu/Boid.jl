"""
The Node.jl module defines the Node type and methods

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

export Node

# ------ Functions

import Base.run

# --- Type definitions

using ZMQ

"""
    struct Node

TODO
"""
struct Node
    #=
      Fields
      ------
      * __Attributes__

        * `id`: id

      * __Components__

        * `control_unit`: control unit

        * `processing_core`: processing core

      * __Communication Channels__

      * `output_url`: URL that Nodes publishes outputs to

      * `output_channel`: channel for publishing output

      * `input_urls`: URLs that Nodes listens for inputs on

      * `input_channels`: channels for listening for inputs
    =#

    # Attributes
    id::String

    # Components
    processing_core::AbstractProcessingCore
    control_unit::ControlUnit
    output_channel::OutputChannel
    input_channels::Vector{InputChannel}

    """
        Node()

    output_channel_params
        output_url
        output_data_type
    """
    function Node(id::String,
                  processing_core::AbstractProcessingCore,
                  control_unit_params::Dict,
                  output_channel_params::Dict,
                  input_channel_params::Vector{Dict})

        # --- Check arguments

        # Check for required parameters for control unit
        # TODO

        # Check for required parameters for output channel
        # TODO

        # Check for required parameters for input channels
        # TODO

        # --- Construct components

        # Construct control unit
        control_unit =
            ControlUnit(control_unit_params["state"],
                        control_unit_params["url"],
                        copy_state=get(control_unit_params, "copy_state", true),
                        use_bind=get(control_unit_params, "use_bind", true))

        # Construct output channel
        output_channel =
            OutputChannel(output_channel_params["data_type"],
                          output_channel_params["url"],
                          use_bind=get(output_channel_params, "use_bind", true))

        # Construct input channels
        input_channels = Vector{InputChannel}()
        for params in input_channel_params
            input_channel =
                InputChannel(params["data_type"],
                             params["url"],
                             use_bind=get(params, "use_bind", true))

            push!(input_channels, InputChannel())
        end

        # --- Construct new Node

        node = new(id, processing_core, control_unit,
                   output_channel, input_channels)
    end
end

# --- Method definitions


