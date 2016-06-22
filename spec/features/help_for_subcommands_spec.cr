require "../spec_helper"

module Cli::Test::HelpForSubcommandsFeature
  class Package < ::Cli::Supercommand
    command "install", default: true
    command "update"
    command "remove"
    command "uninstall", aliased: "remove"

    class Help
      title "#{global_name} [SUBCOMMAND] | [OPTIONS]"
    end

    class Options
      on("--help", desc: "show this help") { command.help! }
    end

    class Base < Cli::Command
      class Help
        title { "#{global_name} [OPTIONS] PACKAGE_NAME" }
      end

      class Options
        on("--help", desc: "show this help") { command.help! }
      end
    end

    module Commands
      class Install < Base
        class Options
          string "-v", var: "VERSION", desc: "specify package's version"
        end

        class Help
          caption "install package"
        end
      end

      class Update < Base
        class Help
          caption "update package"
        end

        class Options
          bool "--major", desc: "update major version if any"
        end
      end

      class Remove < Base
        class Help
          caption "remove package"
        end

        class Options
          bool "-f", desc: "force to remove"
        end
      end
    end
  end

  ::describe "Help for Subcommands" do
    it "prints supercommand's help" do
      io, _ = ::Cli::Test::Stdio.capture do
        Package.run(%w(--help))
      end
      io.output.gets_to_end.should eq <<-EOS
        package [SUBCOMMAND] | [OPTIONS]

        Subcommands:
          install (default)  install package
          remove             remove package
          uninstall          alias for remove
          update             update package

        Options:
          --help  show this help\n
        EOS
    end

    it "prints install's help" do
      io, _ = ::Cli::Test::Stdio.capture do
        Package.run(%w(install --help))
      end
      io.output.gets_to_end.should eq <<-EOS
        package install [OPTIONS] PACKAGE_NAME

        Options:
          -v VERSION  specify package's version
          --help      show this help\n
        EOS
    end

    it "prints update's help" do
      io, _ = ::Cli::Test::Stdio.capture do
        Package.run %w(update --help)
      end
      io.output.gets_to_end.should eq <<-EOS
        package update [OPTIONS] PACKAGE_NAME

        Options:
          --major  update major version if any
          --help   show this help\n
        EOS
    end

    it "prints remove's help" do
      io, _ = ::Cli::Test::Stdio.capture do
        Package.run %w(remove --help)
      end
      io.output.gets_to_end.should eq <<-EOS
        package remove [OPTIONS] PACKAGE_NAME

        Options:
          -f      force to remove
          --help  show this help\n
        EOS
    end

    it "prints uninstall's help" do
      io, _ = ::Cli::Test::Stdio.capture do
        Package.run %w(uninstall --help)
      end
      io.output.gets_to_end.should eq <<-EOS
        package remove [OPTIONS] PACKAGE_NAME

        Options:
          -f      force to remove
          --help  show this help\n
        EOS
    end
  end
end
