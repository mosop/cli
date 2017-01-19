module Cli
  abstract class OptionModel < ::Optarg::Model
    @__cli_command : CommandBase?
    def command; __cli_command; end

    def initialize(argv, @__cli_command)
      initialize argv
    end
  end
end

require "./option_model/*"
