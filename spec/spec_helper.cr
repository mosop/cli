require "spec"
require "crystal_plus/dir/.tmp"
require "have_files/spec/dsl"
require "../src/cli"
require "../src/spec"

ENV["CRYSTAL_CLI_ENV"] = ENV["CRYSTAL_CLI_ENV"]? || "test"
