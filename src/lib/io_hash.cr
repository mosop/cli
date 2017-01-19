module Cli
  class IoHash
    @hash = {} of String => IO

    alias NameArg = String | Symbol

    def []=(name : NameArg, writer : IO)
      @hash[name.to_s] = writer
    end

    def [](name : NameArg)
      @hash[name.to_s]
    end

    def remove(name : NameArg)
      @hash.delete name.to_s
    end

    def renew
      IoHash.new.tap do |o|
        @hash.each do |k, v|
          o[k] = renew_io(v)
        end
      end
    end

    def renew_io(io)
      case io
      when Ios::Pipe
        io.renew
      else
        io
      end
    end

    def each
      @hash.each do |kv|
        yield kv[1]
      end
    end

    def close_writer
      each do |io|
        case io
        when Ios::Pipe
          io.close_writer
        end
      end
    end
  end
end
