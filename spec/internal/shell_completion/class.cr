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

    class Subcommand3 < Cli::Command
      replacer_command Subcommand2
    end
  end
end
