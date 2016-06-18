require "../spec_helper"

module Cli::Test::InheritanceFeature
  class Role < Cli::Command
    class Options
      string "--name"
    end
  end

  class Chase < ::Cli::Supercommand
    command "mouse"
    command "cat"

    module Commands
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
  end

  ::describe "Features" do
    it "Inheritance" do
      io, _ = ::Cli::Test::Stdio.capture do
        Chase.run(%w(mouse --name Jerry))
        Chase.run(%w(cat --name Tom))
      end
      io.output.gets_to_end.should eq "Jerry runs away.\nTom runs into a wall.\n"
    end
  end
end
