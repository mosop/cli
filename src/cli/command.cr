require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    def __initialize_options(argv)
      @__option_model = opts = __new_options(argv)
      __rescue_parsing_error do
        opts.__parse
      end
    end
  end
end
