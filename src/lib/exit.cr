module Cli
  # Contains information about exit.
  class Exit < Exception
    # Returns an exit code.
    getter exit_code : Int32

    # Tests if the exit code is zero.
    def success?
      @exit_code == 0
    end

    # Tests if the exit code is non-zero.
    def error?
      !success?
    end

    # :nodoc:
    def stdout
      success? ? STDOUT : STDERR
    end

    # :nodoc:
    def initialize(message = nil, @exit_code = 0)
      super message
    end
  end
end
