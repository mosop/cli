require "../spec_helper"

module Cli::Test::HelpFeature
  class Lang < Cli::Command
    class Help
      title "#{global_name} [OPTIONS]"
      header "Converts a language to other languages."
      footer "(C) 20XX mosop"
    end

    class Options
      string "--from", var: "LANG", desc: "source language"
      array "--to", var: "LANG", desc: "target language", default: %w(ruby crystal)
      string "--indent", var: "NUM", desc: "set number of tab size", default: "2"
      bool "--std", not: "--Std", desc: "use standard library", default: true
      on("--help", desc: "show this help") { command.help! }
    end
  end

  it "Help" do
    Stdio.capture do |io|
      Lang.run %w(--help)
      io.out.gets_to_end.should eq <<-EOS
        lang [OPTIONS]

        Converts a language to other languages.

        Options:
          --from LANG           source language
          --indent NUM          set number of tab size
                                (default: 2)
          --std                 use standard library
                                (enabled as default)
          --Std                 disable --std
          --to LANG (multiple)  target language
                                (default: ruby, crystal)
          --help                show this help

        (C) 20XX mosop\n
        EOS
    end
  end
end
