module Cli
  # Contains named IOs.
  class IoHash
    @hash = {} of String => IO

    alias NameArg = String | Symbol

    # Sets a named IO.
    def []=(name : NameArg, writer : IO)
      @hash[name.to_s] = writer
    end

    # Gets a named IO.
    def [](name : NameArg)
      @hash[name.to_s]
    end

    # :nodoc:
    def remove(name : NameArg)
      @hash.delete name.to_s
    end

    # :nodoc:
    def renew
      IoHash.new.tap do |o|
        @hash.each do |k, v|
          o[k] = renew_io(v)
        end
      end
    end

    # :nodoc:
    def renew_io(io)
      case io
      when Ios::Pipe
        io.renew
      else
        io
      end
    end

    # :nodoc:
    def each
      @hash.each do |kv|
        yield kv[1]
      end
    end

    # :nodoc:
    def close_writer
      each do |io|
        case io
        when Ios::Pipe
          io.close_writer
        when IO
          # IO was no writer
        end
      end
    end
  end
end
