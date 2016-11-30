require "../spec_helper"

module CliInternalDashedSubcommandFeature
  class Command < Cli::Supercommand
    command "dashed-command"

    module Commands
      class DashedCommand < Cli::Command
        def run
          puts "ok"
        end
      end
    end
  end

  it name do
    Stdio.capture do |io|
      Command.run %w(dashed-command)
      io.out.gets_to_end.should eq "ok\n"
    end
  end
end
