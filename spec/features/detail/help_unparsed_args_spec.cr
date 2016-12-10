require "../../spec_helper"

module CliHelpUnparsedArgsFeatureDetail
  include Cli::Spec::Helper

  class Exec < Cli::Command
    class Options
      arg "command", required: true, stop: true, desc: "command name"
      help
    end

    class Help
      unparsed_args "[ARG1 ARG2 ...]"
    end
  end

  it name do
    Exec.run(%w(-h)).should exit_command(output: <<-EOS
      exec [OPTIONS] COMMAND [ARG1 ARG2 ...]

      Arguments:
        COMMAND  command name

      Options:
        -h, --help  show this help
      EOS
    )
  end
end
