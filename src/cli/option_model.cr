module Cli
  abstract class OptionModel < ::Optarg::Model
    class Option
      class Metadata
        getter description : ::String?
        getter default_string : ::String?
        getter variable_name : ::String?

        def initialize(@description = nil, default = nil, @variable_name = nil, @default_string = nil)
          @default_string ||= default.to_s unless default.nil?
        end
      end
    end

    class Argument
      class Metadata
        getter description : ::String?
        getter default_string : ::String?

        def initialize(@description = nil, default = nil)
          @default_string = default.to_s unless default.nil?
        end
      end
    end

    class Handler
      class Metadata
        getter description : ::String?

        def initialize(@description = nil)
        end
      end
    end

    def self.__help_handler
    end

    @__command : ::Cli::CommandBase?

    def initialize(@__command, argv)
      super argv
    end
  end
end

require "./option_model/dsl/*"
