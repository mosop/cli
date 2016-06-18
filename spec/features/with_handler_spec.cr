require "../spec_helper"

module Cli::Test::WithHandlerFeature
  class Command < Cli::Command
    class Options
      on("--go") { command.go(with: "the Wind") }
    end

    def go(with some)
      puts "Gone with #{some}"
      raise ::Cli::Exit.new
    end
  end

  ::describe "With Handler" do
    it "" do
      io, _ = ::Cli::Test::Stdio.capture do
        Command.run(%w(--go))
      end
      io.output.gets_to_end.should eq "Gone with the Wind\n"
    end
  end
end
