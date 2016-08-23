require "../spec_helper"

module CliRecursiveRunFeature
  class Command < Cli::Command
    class Options
      arg "arg", required: true
    end

    def run
      Command.run
    end
  end

  describe name do
    it "returns internal error" do
      Stdio.capture do |io|
        Command.run(%w(arg)).should eq 1
      end
    end
  end
end
