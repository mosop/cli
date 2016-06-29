module Cli
  abstract class OptionModel < ::Optarg::Model
    macro string(names, var = nil, default = nil, desc = nil, help = :option)
      __define_string_option {{names}}
      %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}}, variable_name: {{var}}, help_type: {{help}})
      __add_string_option {{names}}, metadata: %meta, default: {{default}}
    end

    macro bool(names, default = nil, not = %w(), desc = nil, help = :option)
      __define_bool_option {{names}}
      %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}}, help_type: {{help}})
      __add_bool_option {{names}}, metadata: %meta, default: {{default}}, not: {{not}}
    end

    macro array(names, var = nil, default = nil, desc = nil, help = :option)
      {%
        default_string = default && default.join(", ")
      %}
      __define_string_array_option {{names}}
      %meta = __option_metadata_class_of({{names}}).new(description: {{desc}}, default: {{default}}, variable_name: {{var}}, help_type: {{help}}, default_string: {{default_string}})
      __add_string_array_option {{names}}, metadata: %meta, default: {{default}}
    end

    macro on(names, desc = nil, help = :exit, &block)
      __define_handler {{names}} {{block}}
      %meta = __handler_metadata_class_of({{names}}).new(description: {{desc}}, help_type: {{help}})
      __add_handler {{names}}, metadata: %meta
    end

    class Option
      class Metadata
        @description : ::String?
        getter :description

        @default_string : ::String?
        getter :default_string

        @variable_name : ::String?
        getter :variable_name

        @help_type : ::Symbol
        getter :help_type

        def initialize(@description = nil, default = nil, @variable_name = nil, @help_type = nil, @default_string = nil)
          @default_string ||= default.to_s unless default.nil?
        end
      end
    end

    class Handler
      class Metadata
        @description : ::String?
        getter :description

        def initialize(@description = nil)
        end
      end
    end

    @command : ::Cli::CommandBase?

    def initialize(@command, argv)
      super argv
    end
  end
end
