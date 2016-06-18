require "../spec_helper"

module Cli::Test::ArgumentAccessFeature
  class Command < Cli::Command
    class Options
      string "--option"
    end

    def run
      puts "#{options.option} #{args[0]} #{unparsed_args[0]}"
    end
  end

  ::describe "Features" do
    it "Argument Access" do
      io, _ = ::Cli::Test::Stdio.capture do
        Command.run(%w(--option foo bar -- baz))
      end
      io.output.gets_to_end.should eq "foo bar baz\n"
    end
  end
end
