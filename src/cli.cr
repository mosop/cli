require "./lib"

module Cli
  # :nodoc:
  def self.env
    ENV["CRYSTAL_CLI_ENV"]?
  end

  # :nodoc:
  def self.test?
    env == "test"
  end

  # :nodoc:
  def self.new_default_io
    IoHash.new.tap do |io|
      io[:out] = if test?
        Ios::Pipe.new(read_blocking: false, write_blocking: true)
      else
        STDOUT
      end
      io[:err] = if test?
        Ios::Pipe.new(read_blocking: false, write_blocking: true)
      else
        STDERR
      end
    end
  end
end
