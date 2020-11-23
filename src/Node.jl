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
end

# --- Constructors

"""
    Node(id::String,
         processing_core::AbstractProcessingCore,
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

        push!(input_channels, input_channel)
    end

    # --- Construct new Node

    node = Node(id, processing_core, control_unit,
                output_channel, input_channels)
end

# --- Method definitions

function run(node::Node)
    # Start control unit
    @async run(control_unit)

    # Start input channels
    for channel in node.input_channels
        @async listen(channel)
    end

    # Start control unit

    # Restart control unit
    @async run(control_unit)
end
