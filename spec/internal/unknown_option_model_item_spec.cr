require "../spec_helper"

module CliInternalSpecs::UnknownOptionModelItem
  class Command < Cli::Command
    class Options
      string "-s"
      unknown
    end

    def run
      puts options.s?
      puts unparsed_args.join(" ")
    end
  end

  it name do
    Command.run(%w(foo bar baz)) do |cmd|
      cmd.out.gets_to_end.chomp.should eq "\nfoo bar baz"
    end
    Command.run(%w(-s foo bar baz)) do |cmd|
      cmd.out.gets_to_end.chomp.should eq "foo\nbar baz"
    end
  end
end
