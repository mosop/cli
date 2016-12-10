require "../../src/cli"

class Command < Cli::Command
  def run
    exit! code: 99
  end
end

at_exit {|code| puts ":) #{code}"; LibC.exit 0 }

Command.run
