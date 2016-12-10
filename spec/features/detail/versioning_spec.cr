require "../../spec_helper"

module CliVersioningFeatureDetail
  include Cli::Spec::Helper

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
    Command.run(%w(-v)).should exit_command("1.1.0")
    Command.run(%w(inherit -v)).should exit_command("1.1.0")
    Command.run(%w(specific -v)).should exit_command("1.0.0")
  end
end
