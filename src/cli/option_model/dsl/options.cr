class Cli::OptionModel
  macro string(names, var = nil, default = nil, desc = nil, required = nil, stop = nil)
    __define_string_option {{names}}
    %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}}, variable_name: {{var}})
    __add_string_option {{names}}, metadata: %meta, default: {{default}}, required: {{required}}, stop: {{stop}}
  end

  macro bool(names, default = nil, not = nil, desc = nil, stop = nil)
    __define_bool_option {{names}}
    %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}})
    __add_bool_option {{names}}, metadata: %meta, default: {{default}}, not: {{not}}, stop: {{stop}}
  end

  macro array(names, var = nil, default = nil, desc = nil, min = nil)
    {%
      default_string = default && default.join(", ")
    %}
    __define_string_array_option {{names}}
    %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}}, variable_name: {{var}}, default_string: {{default_string}})
    __add_string_array_option {{names}}, metadata: %meta, default: {{default}}, min: {{min}}
  end

  macro arg(name, default = nil, desc = nil, required = nil, stop = nil)
    __define_argument {{name}}
    %meta = __argument_metadata_class_of({{name}}).new(description: {{desc}}, default: {{default}})
    __add_argument {{name}}, metadata: %meta, required: {{required}}, stop: {{stop}}, default: {{default}}
  end

  macro on(names, desc = nil, &block)
    __define_handler {{names}} {{block}}
    %meta = __handler_metadata_class_of({{names}}).new(description: {{desc}})
    __add_handler {{names}}, metadata: %meta
  end

  macro help(names = nil, desc = nil)
    {%
      names ||= %w(-h --help)
      names = [names] if names.class_name != "ArrayLiteral"
      command_class = @type.name.split("::")[0..-2]
    %}
    on({{names}}, desc: ({{desc}} || "show this help")) { __command.__help! }
  end

  macro version(names = nil, desc = nil)
    {%
      names ||= %w(-v --version)
      names = [names] if names.class_name != "ArrayLiteral"
      command_class = @type.name.split("::")[0..-2]
    %}
    on({{names}}, desc: ({{desc}} || "show version")) { __command.__version! }
  end
end
