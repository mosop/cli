require "../../spec_helper"

module CliWikiTheExitWaysNormalReturnFeature
  class Command < Cli::Command
    def run
      ":)"
    end
  end

  it name do
    Command.run.should eq ":)"
  end
end
