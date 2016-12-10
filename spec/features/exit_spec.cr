require "../spec_helper"

module CliExitFeature
  include Cli::Spec::Helper

  class Open < Cli::Command
    class Options
      arg "word"
    end

    def valid?
      args.word == "sesame"
    end

    def run
      if valid?
        exit! "Opened!"
      else
        error! "Not opened!"
      end
    end
  end

  it name do
    Open.run(%w(sesame)).should exit_command(output: "Opened!", code: 0)
    Open.run(%w(paprika)).should exit_command(error: "Not opened!", code: 1)
  end
end
