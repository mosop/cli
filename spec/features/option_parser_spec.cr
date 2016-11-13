require "../spec_helper"

module CliOptionParserFeature
  class Command < Cli::Command
    class Options
      string "--hello"
    end

    def run
      puts "Hello, #{options.hello}!"
    end
  end

  it name do
    Stdio.capture do |io|
      Command.run %w(--hello world)
      io.out.gets_to_end.should eq "Hello, world!\n"
    end
  end
end
