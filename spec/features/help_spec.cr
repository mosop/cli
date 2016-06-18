require "../spec_helper"

module Cli::Test::HelpFeature
  class Say < Cli::Command
    class Help
      title "#{global_name} [OPTIONS]"
      header "Says something to someone."
      footer "(C) 20XX mosop"
    end

    class Options
      string "--to", var: "WHO", desc: "set someone who you say to", default: "world"
      bool "--hello", not: "--Hello", desc: "say hello", default: true
      on("--help", desc: "show this help") { command.help! }
    end
  end

  ::describe "Help" do
    it "" do
      io, _ = ::Cli::Test::Stdio.capture do
        Say.run(%w(--help))
      end
      io.output.gets_to_end.should eq <<-EOS
        say [OPTIONS]

        Says something to someone.

        Options:
          --hello   say hello
                    (enabled as default)
          --Hello   disable --hello
          --to WHO  set someone who you say to
                    (default: world)
          --help    show this help

        (C) 20XX mosop\n
        EOS
    end
  end
end
