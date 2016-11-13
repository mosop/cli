require "../spec_helper"

module CliInternalCommandBaseRunReturnsZeroFeature
  class Command < Cli::Command
    def run
      1
    end
  end

  it name do
    Command.run.should eq 0
  end
end
