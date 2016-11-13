require "../spec_helper"

module CliInternalRescueParsingErrorFeature
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
      status, err = Stdio.capture do |io|
        status = {{command}}.run({{args}})
        {status, io.err.gets_to_end}
      end
      status.should eq 1
      err.should match(/Parsing Error/)
    end
  end

  test RequiredArgument
  test RequiredOption
  test MinimumLength
  test UnknownOption, %w(-s)
  test MissingValue, %w(-s)
  test UnsupportedConcatenation, %w(-sb)
end
