module Cli::Ios
  class Pipe
    class Closed < Exception
      def initialize(io)
        super "Piped #{io} already closed."
      end
    end

    include IO

    @reader : IO::FileDescriptor?
    @writer : IO::FileDescriptor?
    @read_blocking : Bool
    @write_blocking : Bool

    def initialize(@read_blocking = false, @write_blocking = false)
      @reader, @writer = IO.pipe(read_blocking: @read_blocking, write_blocking: @write_blocking)
    end

    def read(slice : Slice(UInt8))
      if io = @reader
        io.read slice
      else
        raise Closed.new("reader")
      end
    end

    def write(slice : Slice(UInt8))
      if io = @writer
        io.write slice
      else
        raise Closed.new("writer")
      end
    end

    def close
      @reader.try(&.close)
      @reader = nil
      close_writer
    end

    def close_writer
      @writer.try(&.close)
      @writer = nil
    end

    def finalize
      close
    end

    def renew
      Pipe.new(@read_blocking, @write_blocking)
    end
  end
end
