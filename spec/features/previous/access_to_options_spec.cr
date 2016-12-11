require "../../spec_helper"

module CliAccessToOptionsPreviousFeature
  class Command < Cli::Command
    class Options
      string "--option"
      terminator "--"
    end

    def run
      puts "#{options.option} #{args[0]} #{unparsed_args[0]}"
    end
  end

  it name do
    Command.run %w(--option foo bar -- baz) do |cmd|
      cmd.out.gets_to_end.should eq "foo bar baz\n"
    end
  end
end
