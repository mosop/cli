require "../../src/cli"

class FinallySmile < Cli::Command
  after_exit do |cmd, exit|
    cmd.puts exit.message
    cmd.puts ":)"
  end

  def run
    exit! ":("
  end
end

FinallySmile.run
