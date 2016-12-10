require "../spec_helper"

module CliInternalInclusionFeature
  include Cli::Spec::Helper

  class ByArray < Cli::Command
    class Options
      arg "arg", desc: "description", any_of: %w(a b c)
      help
    end
  end

  class ByTuple < Cli::Command
    class Options
      arg "arg", desc: "description", any_of: {
        {"a", {desc: "foo"}},
        {"b", "bar"},
        {"c"}
      }
      help
    end
  end

  describe name do
    it "error" do
      ByArray.run(%w(d)).should exit_command(error: /^Parsing Error: /)
      ByTuple.run(%w(d)).should exit_command(error: /^Parsing Error: /)
    end

    it "help" do
      ByArray.run(%w(-h)).should exit_command(output: <<-EOS
        by-array [OPTIONS] ARG

        Arguments:
          ARG  description
               one of:
                 a
                 b
                 c

        Options:
          -h, --help  show this help
        EOS
      )

      ByTuple.run(%w(-h)).should exit_command(output: <<-EOS
        by-tuple [OPTIONS] ARG

        Arguments:
          ARG  description
               one of:
                 a  foo
                 b  bar
                 c

        Options:
          -h, --help  show this help
        EOS
      )
    end
  end
end
