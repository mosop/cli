require "../spec_helper"

module CliInternalRescueParsingErrorFeature
  include Cli::Spec::Helper

  class RequiredArgument < Cli::Command
    class Options
      arg "arg", required: true
    end
  end

  class RequiredOption < Cli::Command
    class Options
      string "-s", required: true
    end
  end

  class MinimumLength < Cli::Command
    class Options
      array "-a", min: 1
    end
  end

  class UnknownOption < Cli::Command
  end

  class MissingValue < Cli::Command
    class Options
      string "-s"
    end
  end

  class UnsupportedConcatenation < Cli::Command
    class Options
      string "-s"
      bool "-b"
    end
  end

  macro test(command, args = %w())
    it {{command}}.to_s do
      {{command}}.run({{args}}).should exit_command(error: /^Parsing Error: /, code: 1)
    end
  end

  test RequiredArgument
  test RequiredOption
  test MinimumLength
  test UnknownOption, %w(-s)
  test MissingValue, %w(-s)
  test UnsupportedConcatenation, %w(-sb)
end
