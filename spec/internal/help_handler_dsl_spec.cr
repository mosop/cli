require "../spec_helper"

module CliHelpHandlerDslFeature
  class Command < Cli::Command
    class Options
      help
    end
  end

  it name do
    handler = Command::Options.__handlers["-h"]
    handler.names.should eq %w(-h --help)
    out = Stdio.capture do |io|
      Command.run %w(-h)
      io.out.gets_to_end
    end
    out.should eq <<-EOS
      command

      Options:
        -h, --help  show this help\n
      EOS
  end
end
