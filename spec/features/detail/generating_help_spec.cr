require "../../spec_helper"

module CliGeneratingHelpFeatureDetail
  include Cli::Spec::Helper

  class Smile < Cli::Command
    class Help
      header "Smiles n times."
      footer "(C) 20XX mosop"
    end

    class Options
      arg "face", required: true, desc: "your face like :), :(, :P"
      string "--times", var: "NUMBER", default: "1", desc: "number of times to display"
      help
    end
  end

  it name do
    Smile.run(%w(--help)).should exit_command(output: <<-EOS
      smile [OPTIONS] FACE

      Smiles n times.

      Arguments:
        FACE  your face like :), :(, :P

      Options:
        --times NUMBER  number of times to display
                        (default: 1)
        -h, --help      show this help

      (C) 20XX mosop
      EOS
    )
  end
end
