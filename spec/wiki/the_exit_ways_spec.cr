require "../spec_helper"

module CliWikiTheExitWaysFeature
  module NormalReturn
    class Command < Cli::Command
      def run
        ":)"
      end
    end

    it name do
      Command.run.should eq ":)"
    end
  end
end
