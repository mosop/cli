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
    Stdio.capture do |io|
      Chase.run(%w(mouse --name Jerry))
      Chase.run(%w(cat --name Tom))
      io.out.gets_to_end.should eq "Jerry runs away.\nTom runs into a wall.\n"
    end
  end
end
