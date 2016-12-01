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
    Stdio.capture do |io|
      Polygon.run %w(triangle)
      Polygon.run %w(square)
      Polygon.run %w(hexagon)
      Polygon.run %w()
      io.out.gets_to_end.should eq "3\n4\n6\n3\n"
    end
  end
end
