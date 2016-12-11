module Cli
  class Exit < Exception
    getter exit_code : Int32

    def success?
      @exit_code == 0
    end

    def error?
      !success?
    end

    def stdout
      success? ? STDOUT : STDERR
    end

    def initialize(message = nil, @exit_code = 0)
      super message
    end
  end
end
