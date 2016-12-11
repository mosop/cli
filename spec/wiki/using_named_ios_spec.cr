require "../spec_helper"

module CliWikiUsingNamedIosFeature
  module SettingCustomNamedIos
    MEMORY = IO::Memory.new

    class SmileLog < Cli::Command
      on_initialize do |cmd|
        cmd.io[:smiles] = MEMORY
      end

      def run
        io[:smiles].puts ":)"
      end
    end

    it name do
      SmileLog.run do |cmd|
        cmd.io[:smiles].to_s.should eq ":)\n"
      end
    end
  end
end
