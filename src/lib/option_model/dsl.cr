class Cli::OptionModel
  # Defines a String option model item.
  macro string(names, stop = nil, default = nil, required = nil, desc = nil, var = nil, any_of = nil, complete = nil, &block)
    ::Optarg::Model.string(
      {{names}},
      default: {{default}},
      required: {{required}},
      stop: {{stop}},
      metadata: ::Cli::OptionMetadata.new(description: {{desc}}, variable_name: {{var}}),
      any_of: ::Cli.__any_of(::Optarg::Definitions::StringOption, {{any_of}}),
      complete: {{complete}}
    ) {{block}}
  end

  # Defines a Bool option model item.
  macro bool(names, stop = nil, default = nil, not = nil, desc = nil, &block)
    ::Optarg::Model.bool(
      {{names}},
      stop: {{stop}},
      default: {{default}},
      not: {{not}},
      metadata: ::Cli::OptionMetadata.new(description: {{desc}})
    ) {{block}}
  end

  # Defines an Array(String) option model item.
  macro array(names, default = nil, min = nil, desc = nil, var = nil, any_item_of = nil, complete = nil, &block)
    ::Optarg::Model.array(
      {{names}},
      default: {{default}},
      min: {{min}},
      metadata: ::Cli::OptionMetadata.new(description: {{desc}}, variable_name: {{var}}),
      any_item_of: ::Cli.__any_item_of(::Optarg::Definitions::StringArrayOption, {{any_item_of}}),
      complete: {{complete}}
    ) {{block}}
  end

  # Defines a String argument model item.
  macro arg(name, stop = nil, default = nil, required = nil, desc = nil, any_of = nil, complete = nil, &block)
    ::Optarg::Model.arg(
      {{name}},
      stop: {{stop}},
      default: {{default}},
      required: {{required}},
      metadata: ::Cli::OptionMetadata.new(description: {{desc}}),
      any_of: ::Cli.__any_of(::Optarg::Definitions::StringArgument, {{any_of}}),
      complete: {{complete}}
    ) {{block}}
  end

  # Defines an Array(String) argument model item.
  macro arg_array(names, default = nil, min = nil, desc = nil, var = nil, any_item_of = nil, complete = nil, &block)
    ::Optarg::Model.arg_array(
      {{names}},
      default: {{default}},
      min: {{min}},
      metadata: ::Cli::OptionMetadata.new(description: {{desc}}, variable_name: {{var}}),
      any_item_of: ::Cli.__any_item_of(::Optarg::Definitions::StringArrayArgument, {{any_item_of}}),
      complete: {{complete}}
    ) {{block}}
  end

  # Defines a handler model item.
  macro on(names, desc = nil, &block)
    ::Optarg::Model.on({{names}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}})) {{block}}
  end

  # Defines a handler model item for printing a help message.
  macro help(names = nil, desc = nil)
    {%
      names = names || %w(-h --help)
    %}
    on({{names}}, desc: ({{desc}} || "show this help")) { __cli_command.help! }
  end

  # Defines a handler model item for printing a version string.
  macro version(names = nil, desc = nil)
    {%
      names = names || %w(-v --version)
    %}
    on({{names}}, desc: ({{desc}} || "show version")) { __cli_command.version! }
  end
end
