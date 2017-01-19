module Cli
  class OptionMetadata < Optarg::Metadata
    getter description : ::String?
    getter variable_name : ::String?

    def initialize(@description = nil, @variable_name = nil)
    end

    def display_name
      if definition.is_a?(Optarg::DefinitionMixins::Argument)
        definition.key.upcase
      else
        super
      end
    end
  end
end
