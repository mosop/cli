module Cli::OptionModelDefinitionMixins
  module Cli
    macro included
      class Typed
        class ValidationContext
          def command
            parser.data.as(Model).__command
          end
        end
      end
    end
  end
end
