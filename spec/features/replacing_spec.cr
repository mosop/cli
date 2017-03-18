require "../spec_helper"

module CliReplacingFeature
  class New < Cli::Command
    def run
      puts "new!"
    end
  end

  class Obsolete < Cli::Command
    replacer_command New
  end

  it name do
    Obsolete.run do |cmd|
      cmd.out.gets_to_end.chomp.should eq "new!"
    end
  end
end
