require "../spec_helper"

module CliCommandMethodCantBeOverridenFeature
  class Command < Cli::Command
    class Options
      string "--command"
      on("--on") { puts command.class.name }
    end

    def run
      puts options.command
    end
  end

  it name do
    Stdio.capture do |io|
      Command.run %w(--on --command command)
      io.out.gets_to_end.should eq "CliCommandMethodCantBeOverridenFeature::Command\ncommand\n"
    end
  end
end
