require "../spec_helper"

module CliInternalInclusionFeature
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
      Stdio.capture do |io|
        ByArray.run %w(d)
        io.err.gets.should match /^Parsing Error: /
      end
      Stdio.capture do |io|
        ByTuple.run %w(d)
        io.err.gets.should match /^Parsing Error: /
      end
    end

    it "help" do
      Stdio.capture do |io|
        ByArray.run %w(-h)
        io.out.gets_to_end.should eq <<-EOS
        by-array [OPTIONS] ARG

        Arguments:
          ARG  description
               one of:
                 a
                 b
                 c

        Options:
          -h, --help  show this help\n
        EOS
      end
      Stdio.capture do |io|
        ByTuple.run %w(-h)
        io.out.gets_to_end.should eq <<-EOS
        by-tuple [OPTIONS] ARG

        Arguments:
          ARG  description
               one of:
                 a  foo
                 b  bar
                 c

        Options:
          -h, --help  show this help\n
        EOS
      end
    end
  end
end
