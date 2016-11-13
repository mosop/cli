require "../../spec_helper"

module CliHelpUnparsedArgsFeatureDetail
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
    out = Stdio.capture do |io|
      Exec.run %w(-h)
      io.out.gets_to_end
    end
    out.should eq <<-EOS
      exec COMMAND [ARG1 ARG2 ...]

      Arguments:
        COMMAND  command name

      Options:
        -h, --help  show this help\n
      EOS
  end
end
