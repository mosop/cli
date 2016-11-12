class Optarg::Model
  @__command : ::Cli::CommandBase?

  def command
    @__command
  end

  def initialize(@__command, argv)
    initialize argv
  end
end

module Cli
  abstract class OptionModel < ::Optarg::Model
    class Option
      def optional?
        o = self
        if o.responds_to?(:required?)
          !(default.nil? && o.required?)
        else
          true
        end
      end

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
      def optional?
        !(default.nil? && required?)
      end

      def display_name
        super.upcase
      end

      class Metadata
        getter description : ::String?
        getter default_string : ::String?

        def initialize(@description = nil, default = nil)
          @default_string = default.to_s unless default.nil?
        end
      end
    end

    class Handler
      def optional?
        true
      end

      class Metadata
        getter description : ::String?

        def initialize(@description = nil)
        end
      end
    end
  end
end

require "./option_model/dsl/*"
