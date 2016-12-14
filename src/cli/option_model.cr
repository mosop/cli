module Cli
  abstract class OptionModel < ::Optarg::Model
    @__command : CommandBase?
    def command; __command; end

    def initialize(argv, @__command)
      initialize argv
    end
  end
end
