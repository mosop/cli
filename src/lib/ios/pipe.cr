module Cli::Ios
  class Pipe < IO
    # :nodoc:
    class Closed < Exception
      def initialize(io)
        super "Piped #{io} already closed."
      end
    end

    @reader : IO::FileDescriptor?
    @writer : IO::FileDescriptor?
    @read_blocking : Bool
    @write_blocking : Bool

    # :nodoc:
    def initialize(@read_blocking = false, @write_blocking = false)
      @reader, @writer = IO.pipe(read_blocking: @read_blocking, write_blocking: @write_blocking)
    end

    # Implements `IO#read`.
    def read(slice : Slice(UInt8))
      if io = @reader
        io.read slice
      else
        raise Closed.new("reader")
      end
    end

    # Implements `IO#write`.
    def write(slice : Slice(UInt8))
      if io = @writer
        io.write slice
      else
        raise Closed.new("writer")
      end
    end

    # :nodoc:
    def close
      @reader.try(&.close)
      @reader = nil
      close_writer
    end

    # :nodoc:
    def close_writer
      @writer.try(&.close)
      @writer = nil
    end

    # :nodoc:
    def finalize
      close
    end

    # :nodoc:
    def renew
      Pipe.new(@read_blocking, @write_blocking)
    end
  end
end
