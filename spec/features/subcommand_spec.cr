require "../spec_helper"

module CliSubcommandFeature
  class Polygon < Cli::Supercommand
    command "triangle", default: true

    class Triangle < Cli::Command
      def run
        puts 3
      end
    end

    class Square < Cli::Command
      def run
        puts 4
      end
    end

    class Hexagon < Cli::Command
      def run
        puts 6
      end
    end
  end

  it name do
    Polygon.run %w(triangle) do |cmd|
      cmd.out.gets_to_end.should eq "3\n"
    end
    Polygon.run %w(square) do |cmd|
      cmd.out.gets_to_end.should eq "4\n"
    end
    Polygon.run %w(hexagon) do |cmd|
      cmd.out.gets_to_end.should eq "6\n"
    end
    Polygon.run %w() do |cmd|
      cmd.out.gets_to_end.should eq "3\n"
    end
  end
end
