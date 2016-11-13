require "../../spec_helper"

module CliVersioningFeatureDetail
  class Command < ::Cli::Supercommand
    version "1.1.0"
    command "inherit"
    command "specific"

    class Options
      version
    end

    module Commands
      class Inherit < ::Cli::Command
        class Options
          version
        end
      end

      class Specific < ::Cli::Command
        version "1.0.0"

        class Options
          version
        end
      end
    end
  end

  it name do
    Stdio.capture do |io|
      Command.run %w(-v)
      io.out.gets_to_end.should eq "1.1.0\n"
    end

    Stdio.capture do |io|
      Command.run %w(inherit -v)
      io.out.gets_to_end.should eq "1.1.0\n"
    end

    Stdio.capture do |io|
      Command.run %w(specific -v)
      io.out.gets_to_end.should eq "1.0.0\n"
    end
  end
end
