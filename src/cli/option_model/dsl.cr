class Cli::OptionModel
  macro string(names, stop = nil, default = nil, required = nil, desc = nil, var = nil, any_of = nil)
    ::Optarg::Model.string {{names}}, default: {{default}}, required: {{required}}, stop: {{stop}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}}, variable_name: {{var}}), any_of: ::Cli.__any_of(::Optarg::Definitions::StringOption, {{any_of}})
  end

  macro bool(names, stop = nil, default = nil, not = nil, desc = nil)
    ::Optarg::Model.bool {{names}}, stop: {{stop}}, default: {{default}}, not: {{not}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}})
  end

  macro array(names, default = nil, min = nil, desc = nil, var = nil)
    ::Optarg::Model.array {{names}}, default: {{default}}, min: {{min}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}}, variable_name: {{var}})
  end

  macro arg(name, stop = nil, default = nil, required = nil, desc = nil, any_of = nil)
    ::Optarg::Model.arg {{name}}, stop: {{stop}}, default: {{default}}, required: {{required}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}}), any_of: ::Cli.__any_of(::Optarg::Definitions::StringArgument, {{any_of}})
  end

  macro on(names, desc = nil, &block)
    ::Optarg::Model.on({{names}}, metadata: ::Cli::OptionMetadata.new(description: {{desc}})) {{block}}
  end

  macro help(names = nil, desc = nil)
    {%
      names ||= %w(-h --help)
    %}
    on({{names}}, desc: ({{desc}} || "show this help")) { __command.__help! }
  end

  macro version(names = nil, desc = nil)
    {%
      names ||= %w(-v --version)
    %}
    on({{names}}, desc: ({{desc}} || "show version")) { __command.__version! }
  end
end
