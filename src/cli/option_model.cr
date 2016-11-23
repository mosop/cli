module Cli
  abstract class OptionModel < ::Optarg::Model
    getter __command : ::Cli::CommandBase
    def command; __command; end

    def initialize(@__command, argv)
      initialize argv
    end
  end
end
