require "../spec_helper"

module Cli::Test::HelpFeature
  class Lang < Cli::Command
    class Help
      header "Converts a language to other languages."
      footer "(C) 20XX mosop"
    end

    class Options
      arg "from", desc: "source language", required: true
      array "--to", var: "LANG", desc: "target language", default: %w(crystal)
      string "--indent", var: "NUM", desc: "set number of tab size", default: "2"
      bool "--std", not: "--Std", desc: "use standard library", default: true
      help
    end
  end

  it "Help" do
    Stdio.capture do |io|
      Lang.run %w(--help)
      io.out.gets_to_end.should eq <<-EOS
        lang [OPTIONS] FROM

        Converts a language to other languages.

        Arguments:
          FROM  source language

        Options:
          --indent NUM          set number of tab size
                                (default: 2)
          --std                 use standard library
                                (enabled as default)
          --Std                 disable --std
          --to LANG (multiple)  target language
                                (default: crystal)
          -h, --help            show this help

        (C) 20XX mosop\n
        EOS
    end
  end
end
