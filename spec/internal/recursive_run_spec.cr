require "../spec_helper"

module CliInternalRecursiveRunFeature
  include Cli::Spec::Helper

  class Command < Cli::Command
    class Options
      arg "arg", required: true
    end

    def run
      run Command
    end
  end

  describe name do
    it "returns internal error" do
      Command.run(%w(arg)).should exit_command(error: /^Parsing Error: /)
    end
  end
end
