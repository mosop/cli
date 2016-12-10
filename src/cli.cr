require "optarg"
require "string_inflection/kebab"
require "string_inflection/snake"
require "./cli/macros/*"
require "./cli/*"
require "./cli/command_class/*"
require "./cli/helps/*"
require "./cli/option_model/*"
require "./cli/option_model_definition_mixins/*"
require "./cli/option_model_definitions/*"
require "./cli/util/*"

module Cli
  def self.env
    ENV["CRYSTAL_CLI_ENV"]?
  end

  def self.test?
    env == "test"
  end
end
