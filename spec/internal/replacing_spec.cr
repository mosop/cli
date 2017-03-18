require "../spec_helper"

module CliInternalSpecs::Replacing
  include Cli::Spec::Helper

  class New < Cli::Command
    class Options
      string "-s"
      help
    end

    def run
      puts options.s
    end
  end

  class Obsolete < Cli::Command
    replacer_command New
  end

  describe name do
    it "works" do
      Obsolete.run %w(-s new!) do |cmd|
        cmd.out.gets_to_end.chomp.should eq "new!"
      end
    end

    it "help" do
      Obsolete.run(%w(-h)).should exit_command(output: <<-EOS
      new [OPTIONS]

      Options:
        -s
        -h, --help  show this help
      EOS
      )
    end
  end
end
