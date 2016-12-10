module Cli
  class Exit < ::Exception
    getter status : Int32

    def initialize(message = nil, @status = 0)
      super message
    end

    def exit!
      out = status == 0 ? STDOUT : STDERR
      out.puts message if message
      if Cli.test?
        raise self
      else
        ::exit status
      end
    end
  end

  class UnknownCommand < ::Exception
    def initialize(name)
      super "Unknown command: #{name}"
    end
  end
end
