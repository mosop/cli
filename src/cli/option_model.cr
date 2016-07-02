module Cli
  abstract class OptionModel < ::Optarg::Model
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

    class Argument
      class Metadata
        @description : ::String?
        getter :description

        @default_string : ::String?
        getter :default_string

        @help_type : ::Symbol
        getter :help_type

        def initialize(@description = nil, default = nil, @help_type = nil)
          @default_string = default.to_s unless default.nil?
        end
      end
    end

    class Handler
      class Metadata
        @description : ::String?
        getter :description

        @help_type : ::Symbol
        getter :help_type

        def initialize(@description = nil, @help_type = nil)
        end
      end
    end

    @__command : ::Cli::CommandBase?

    def initialize(@__command, argv)
      super argv
    end
  end
end

require "./option_model/dsl/*"
