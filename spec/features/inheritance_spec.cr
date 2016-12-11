require "../spec_helper"

module CliInheritanceFeature
  abstract class Role < Cli::Command
    class Options
      string "--name"
    end
  end

  class Chase < ::Cli::Supercommand
    class Mouse < Role
      def run
        puts "#{options.name} runs away."
      end
    end

    class Cat < Role
      def run
        puts "#{options.name} runs into a wall."
      end
    end
  end

  it name do
    Chase.run %w(mouse --name Jerry) do |cmd|
      cmd.out.gets_to_end.should eq "Jerry runs away.\n"
    end
    Chase.run(%w(cat --name Tom)) do |cmd|
      cmd.out.gets_to_end.should eq "Tom runs into a wall.\n"
    end
  end
end
