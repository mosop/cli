require "../../spec_helper"

module CliGeneratingHelpFeatureDetail
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
    Stdio.capture do |io|
      Smile.run %w(--help)
      io.out.gets_to_end.should eq <<-EOS
        smile [OPTIONS] FACE

        Smiles n times.

        Arguments:
          FACE  your face like :), :(, :P

        Options:
          --times NUMBER  number of times to display
                          (default: 1)
          -h, --help      show this help

        (C) 20XX mosop\n
        EOS
    end
  end
end
