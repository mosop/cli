module Cli
  class Exit < ::Exception
    @status : ::Int32
    getter :status

    def initialize(message = nil, @status = 0)
      super message
    end
  end

  class UnknownCommand < ::Exception
    def initialize(name)
      super "Unknown command: #{name}"
    end
  end
end
