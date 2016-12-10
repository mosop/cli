require "../../spec_helper"

module CliWikiHandlingExitNonExplicitFeature
  class Command < Cli::Command
    def run
      ":)"
    end
  end

  it name do
    Command.run.should eq ":)"
  end
end
