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

      * __Processing Components__

        * `processing_core`: processing core

        * `data`: data storage

      * __Node Operation Components__

        * `control_unit`: control unit

        * `output_channel`: channel for publishing output

        * `input_channels`: channels for listening for inputs
    =#

    # Attributes
    id::String

    # Processing Components
    processing_core::AbstractProcessingCore
    data::AbstractNodeData

    # Node Operation Components
    control_unit::ControlUnit
    output_channel::OutputChannel
    input_channels::Vector{InputChannel}
end

# --- Constructors

"""
    Node(id::String,
         processing_core::AbstractProcessingCore,
         data_type::Type{<:AbstractNodeData},
         control_unit_params::Dict,
         output_channel_params::Dict,
         input_channel_params::Vector{Dict})

Construct a distributable, autonomous compute node identified by `id` and that
uses `processing_core` to process data that it receives. `control_unit_params`,
`output_channel_params`, and `input_channel_params` define the Node's control
unit, output channel, and input channels, respectively.

### ControlUnit Parameters

* `state`<:AbstractControlState - control state for Node

* `url`::String - URL that the ControlUnit listens for control signals on

* `copy_state`::Bool - set to true if the ControlUnit should be initialized
  with a copy of `state`; set to false otherwise

* `use_bind`::Bool - set to true if the ZMQ Socket that the ControlUnit
  listens for control signals on should be connected to `url` using the
  `bind()` method; set to false if the ZMQ Socket should be connected using
  the `connect()` method. For the ControlUnit, defaults to `true`.

### OutputChannel Parameters

* `data_type`::Type - subtype of AbstractChannelData that output channel
  publishes

* `url`::String - URL that the OutputChannel publishes data to

* `use_bind`::Bool - set to true if the ZMQ Socket that the OutputChannel
  publishes data on should be connected to `url` using the `bind()` method;
  set to false if the ZMQ Socket should be connected using the `connect()`
  method. For the OutputChannel, defaults to `true`.

### Input Channel Parameters

* `data_type`::Type - subtype of AbstractChannelData that input channel accepts

* `url`::String - URL that the InputChannel listens for data on

* `use_bind`::Bool - set to true if the ZMQ Socket that the InputChannel
  listens for data on should be connected to `url` using the `bind()` method;
  set to false if the ZMQ Socket should be connected using the `connect()`
  method. For the InputChannel, defaults to `false`.
"""
function Node(id::String,
              processing_core::AbstractProcessingCore,
              data_type::Type{<:AbstractNodeData},
              control_unit_params::Dict,
              output_channel_params::Dict,
              input_channel_params::Vector{Dict})

    # --- Check arguments

    # Check for required parameters for control unit
    required_params = ["state", "url"]
    for param in required_params
        if !haskey(control_unit_params, param)
            message = "`control_unit_params` is missing required parameter: " *
                      "`$param`"
            throw(ArgumentError(message))
        end
    end

    # Check for required parameters for output channel
    required_params = ["data_type", "url"]
    for param in required_params
        if !haskey(output_channel_params, param)
            message =
                "`output_channel_params` is missing required parameter: " *
                "`$param`"
            throw(ArgumentError(message))
        end
    end

    # Check for required parameters for input channels
    required_params = ["data_type", "url"]
    for i in 1:length(input_channel_params)
        for param in required_params
            if !haskey(input_channel_params[i], param)
                message =
                    "`input_channel_params[$i]` is missing required " *
                    "parameter: `$param`"
                throw(ArgumentError(message))
            end
        end
    end

    # --- Construct components

    # Construct data
    data = data_type()

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

        push!(input_channels, input_channel)
    end

    # --- Construct new Node

    node = Node(id, processing_core, data,
                control_unit, output_channel, input_channels)
end

# --- Method definitions

function run(node::Node)
    # Start control unit
    @async run(control_unit)

    # Start input channels
    for channel in node.input_channels
        @async listen(channel)
    end

    # Run main processing loop
    # TODO
end
