require "../spec_helper"

module Cli::Test::OptionParserFeature
  class Command < Cli::Command
    class Options
      string "--hello"
    end

    def run
      puts "Hello, #{options.hello}!"
    end
  end

  ::describe "Features" do
    it "Option Parser" do
      io, _ = ::Cli::Test::Stdio.capture do
        Command.run(%w(--hello world))
      end
      io.output.gets_to_end.should eq "Hello, world!\n"
    end
  end
end
