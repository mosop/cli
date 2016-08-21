require "../spec_helper"

module CliCustomCommandNameFeature
  class Command < Cli::Supercommand
    command_name "custom"
  end

  it name do
    Command::Help.global_name.should eq "custom"
  end
end
