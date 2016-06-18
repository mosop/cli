lib LibC
  fun dup(oldfd : Int) : Int
end

module Cli::Test
  class Stdio
    class Out
      @dup : ::LibC::Int
      @close_on_exec : ::Bool
      @reader : ::IO::FileDescriptor
      @writer : ::IO::FileDescriptor

      getter :reader, :writer

      def initialize(@io : ::IO::FileDescriptor)
        @io = io
        @dup = -1
        @close_on_exec = true
        @reader, @writer = ::IO.pipe
      end

      def capture
        raise "Already captured." if @dup != -1
        @close_on_exec = @io.close_on_exec?
        @dup = ::LibC.dup(@io.fd)
        raise "dup() error." if @dup == -1
        @io.reopen @writer
        @io.close_on_exec = @close_on_exec
      end

      def uncapture
        raise "Not captured." if @dup == -1
        raise "dup2() error." if ::LibC.dup2(@dup, @io.fd) == -1
        @io.close_on_exec = @close_on_exec
        @dup = -1
      end
    end

    def output
      @stdout.reader
    end

    def error
      @stderr.reader
    end

    def initialize
      @stdout = Out.new(::STDOUT)
      @stderr = Out.new(::STDERR)
    end

    def capture(&block)
      @stdout.capture
      @stderr.capture
      begin
        yield
      ensure
        @stdout.uncapture
        @stderr.uncapture
      end
    end

    def depipe
      @stdout.writer.close
      @stderr.writer.close
    end

    def self.capture(&block)
      io = new
      result = io.capture do
        yield
      end
      io.depipe
      {io, result}
    end
  end
end
