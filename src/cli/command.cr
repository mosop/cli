require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    def __initialize_options(argv)
      @__options = opts = __new_options(argv)
      opts.__parse
    end
  end
end
