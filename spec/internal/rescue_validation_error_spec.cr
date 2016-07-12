require "../spec_helper"

module CliRescueValidationErrorFeature
  class Command < Cli::Command
    class Options
      arg "required", required: true
    end
  end

  it name do
    status, err = Stdio.capture do |io|
      status = Command.run
      {status, io.err.gets_to_end}
    end
    status.should eq 1
    err.should match(/Parsing Error/)
  end
end
