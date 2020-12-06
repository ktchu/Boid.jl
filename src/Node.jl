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

        * `processing_core`: processing core

        * `control_unit`: control unit

        * `output_channel`: channel for publishing output

        * `input_channels`: channels for listening for inputs

        * `input_data`: TODO
    =#

    # Attributes
    id::String

    # Components
    processing_core::AbstractProcessingCore
    control_unit::ControlUnit
    output_channel::OutputChannel
    input_channels::Vector{InputChannel}
    input_data::Vector
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

* `logic_core`<:AbstractControlLogicCore - control logic unit for Node

* `url`::String - URL that the ControlUnit listens for control signals on

* `copy_logic_core`::Bool - set to true if the ControlUnit should be
  initialized with a copy of `logic_core`; set to false if the ControlUnit
  is set to point to the instance referenced by `logic_core`.

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
    required_params = ["logic_core", "url"]
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

    # Construct control unit
    control_unit =
        ControlUnit(control_unit_params["logic_core"],
                    control_unit_params["url"],
                    copy_logic_core=get(control_unit_params,
                                        "copy_logic_core", true),
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

    # Construct storage for input data
    input_data = Vector(undef, length(input_channels))

    # --- Construct new Node

    node = Node(id, processing_core,
                control_unit, output_channel, input_channels, input_data)
end

# --- Method definitions

# Constants
INIT_SLEEP_TIME = 0.001

"""
    run(node::Node)

Activate all of the operational components of `node` and start running the
main processing loop.
"""
function run(node::Node)
    # --- Start input channels

    for channel in node.input_channels
        @async listen(channel)
    end

    # Wait for input channels to be in 'listening' state
    for channel in node.input_channels
        while !is_listening(channel)
            sleep(INIT_SLEEP_TIME)
        end
    end

    # --- Start control unit

    @async run(node.control_unit)

    # Wait for control unit to be in 'running' state
    while !is_running(node)
        sleep(INIT_SLEEP_TIME)
    end

    # --- Run main processing loop

    run_processing_loop!(node)
end

"""
    run_processing_loop!(node::Node)

Run main processing loop.
"""
function run_processing_loop!(node::Node)
    while is_running(node)
        # Wait for input to be ready for processing
        wait_for_input_ready(node.control_unit, node.input_channels)

        # Gather input
        gather_input!(node)

        # Process input
        result = process_data!(node.processing_core, node.input_data)

        # Publish output
        publish(node.output_channel, result)

        # Sleep to give other tasks a chance to run
        # TODO: improve design and implementation. One possibility would
        #       be to use round-robin between control and input processing
        sleep(0.001)
    end
end

"""
    is_running(node::Node)

Return true if the Node is running; return false otherwise.
"""
is_running(node::Node) = is_running(node.control_unit)

"""
    gather_input(node::Node)

Gather input from the input channels of `node`.
"""
function gather_input!(node::Node)
    for (i, channel) in enumerate(node.input_channels)
        node.input_data[i] = get_last_value(channel)
    end
end
