module Cli
  abstract class OptionModel < ::Optarg::Model
    module CliClass
      abstract def __cli_command
    end

    @__command : CommandBase?
    def command; __command; end

    def initialize(argv, @__command)
      initialize argv
    end
  end
end
