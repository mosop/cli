module Cli
  class Exit < ::Exception
    getter exit_code : Int32

    def success?
      @exit_code == 0
    end

    def error?
      !success?
    end

    def initialize(message = nil, @exit_code = 0)
      super message
    end
  end

  class UnknownCommand < ::Exception
    def initialize(name)
      super "Unknown command: #{name}"
    end
  end
end
