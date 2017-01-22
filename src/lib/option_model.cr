module Cli
  # Inherits the Optarg::Model class for parsing command-line arguments.
  abstract class OptionModel < ::Optarg::Model
    @__cli_command : CommandBase?

    # Returns a related command instance.
    def command; __cli_command; end

    # :nodoc:
    def initialize(argv, @__cli_command)
      initialize argv
    end
  end
end

require "./option_model/*"
