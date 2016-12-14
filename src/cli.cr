require "optarg"
require "string_inflection/kebab"
require "string_inflection/snake"
require "./cli/macros/*"
require "./cli/*"
require "./cli/command_class/*"
require "./cli/helps/*"
require "./cli/ios/*"
require "./cli/option_model/*"
require "./cli/option_model_definitions/*"
require "./cli/util/*"

module Cli
  def self.env
    ENV["CRYSTAL_CLI_ENV"]?
  end

  def self.test?
    env == "test"
  end

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
