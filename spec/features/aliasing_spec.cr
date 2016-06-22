require "../spec_helper"

module Cli::Test::AliasingFeature
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

  ::it "Aliasing" do
    io, _ = ::Cli::Test::Stdio.capture do
      Command.run %w(l)
    end
    io.output.gets_to_end.should eq "sleep!\n"
  end
end
