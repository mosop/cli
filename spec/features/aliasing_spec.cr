require "../spec_helper"

module CliAliasingFeature
  class Command < ::Cli::Supercommand
    command "l", aliased: "loooooooooong"

    class Loooooooooong < ::Cli::Command
      def run
        puts "sleep!"
      end
    end
  end

  it name do
    Command.run %w(l) do |cmd|
      cmd.out.gets_to_end.should eq "sleep!\n"
    end
  end
end
