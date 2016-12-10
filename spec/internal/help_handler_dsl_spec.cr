require "../spec_helper"

module CliInternalHelpHandlerDslFeature
  include Cli::Spec::Helper

  class Default < Cli::Command
    class Options
      help
    end
  end

  class Specific < Cli::Command
    class Options
      help "--show-help", desc: "help!"
    end
  end

  macro test(example, klass, names, desc)
    it {{example}} do
      handler = {{klass.id}}::Options.definitions.handlers[{{names[0]}}]
      handler.names.should eq {{names}}
      {% for e, i in names %}
        {{klass.id}}.run([{{e}}]).should exit_command(output: <<-EOS
          {{klass.downcase.id}} [OPTIONS]

          Options:
            #{ ({{names}}).join(", ") }  {{desc.id}}
          EOS
        )
      {% end %}
    end
  end

  describe name do
    test "default", "Default", %w(-h --help), "show this help"
    test "specific", "Specific", %w(--show-help), "help!"
  end
end
