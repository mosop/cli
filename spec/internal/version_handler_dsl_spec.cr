require "../spec_helper"

module CliInternalVersionHandlerDslFeature
  class Default < Cli::Command
    version "1.0.0"
    class Options
      version
    end
  end

  class Specific < Cli::Command
    version "1.0.0"
    class Options
      version "--show-version", desc: "version!"
    end
  end

  macro test(example, klass, names, desc)
    it {{example}} do
      handler = {{klass.id}}::Options.definitions.handlers[{{names[0]}}]
      handler.names.should eq {{names}}
      {% for e, i in names %}
        Stdio.capture do |io|
          {{klass.id}}.run [{{e}}]
          io.out.gets_to_end.should eq "1.0.0\n"
        end
      {% end %}
    end
  end

  describe name do
    test "default", "Default", %w(-v --version), "show version"
    test "specific", "Specific", %w(--show-version), "version!"
  end
end
