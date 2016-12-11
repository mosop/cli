module Cli
  class UnknownCommand < Exception
    def initialize(name)
      super "Unknown command: #{name}"
    end
  end
end
