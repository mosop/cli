require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    def __initialize_options(argv)
      @__option_data = opts = __new_options(argv)
      __rescue_parsing_error do
        opts.__parse
      end
    end

    def self.__finalize_definition
    end
  end
end
