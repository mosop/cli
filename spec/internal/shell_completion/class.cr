module CliInternalSpecs::ShellCompletion
  class Command < Cli::Supercommand
    class Subcommand1 < Cli::Command
      class Options
        string "-s"
      end
    end

    class Subcommand2 < Cli::Command
      class Options
        string "-s"
      end
    end
  end
end
