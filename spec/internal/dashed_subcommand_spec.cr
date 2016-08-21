require "../spec_helper"

module Cli::Test::DashedSubcommandFeature
  class Command < Cli::Supercommand
    command "dashed-command"

    module Commands
      class DashedCommand < Cli::Command
      end
    end
  end

  it "Dashed Subcommand" do
    Stdio.capture do |io|
      Command.run
      io.out.gets_to_end.should eq "command SUBCOMMAND\n\nSubcommands:\n  dashed-command\n"
    end
  end
end
