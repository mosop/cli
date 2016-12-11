require "../../spec_helper"

module CliAliasingPreviousFeature
  class Command < ::Cli::Supercommand
    command "loooooooooong"
    command "l", aliased: "loooooooooong"

    module Commands
      class Loooooooooong < ::Cli::Command
        def run
          puts "sleep!"
        end
      end
    end
  end

  it name do
    Command.run %w(l) do |cmd|
      cmd.out.gets_to_end.should eq "sleep!\n"
    end
  end
end
