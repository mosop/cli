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
      help
    end

    class Base < Cli::Command
      class Options
        arg "package_name", desc: "specify package's name", required: true
        help
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

  describe "Help for Subcommands" do
    it "prints supercommand's help" do
      Stdio.capture do |io|
        Package.run %w(--help)
        io.out.gets_to_end.should eq <<-EOS
          package [SUBCOMMAND] | [OPTIONS]

          Subcommands:
            install (default)  install package
            remove             remove package
            uninstall          alias for remove
            update             update package

          Options:
            -h, --help  show this help\n
          EOS
      end
    end

    it "prints install's help" do
      Stdio.capture do |io|
        Package.run %w(install --help)
        io.out.gets_to_end.should eq <<-EOS
          package install [OPTIONS] PACKAGE_NAME

          Arguments:
            PACKAGE_NAME  specify package's name

          Options:
            -v VERSION  specify package's version
            -h, --help  show this help\n
          EOS
      end
    end

    it "prints update's help" do
      Stdio.capture do |io|
        Package.run %w(update --help)
        io.out.gets_to_end.should eq <<-EOS
          package update [OPTIONS] PACKAGE_NAME

          Arguments:
            PACKAGE_NAME  specify package's name

          Options:
            --major     update major version if any
            -h, --help  show this help\n
          EOS
      end
    end

    it "prints remove's help" do
      Stdio.capture do |io|
        Package.run %w(remove --help)
        io.out.gets_to_end.should eq <<-EOS
          package remove [OPTIONS] PACKAGE_NAME

          Arguments:
            PACKAGE_NAME  specify package's name

          Options:
            -f          force to remove
            -h, --help  show this help\n
          EOS
      end
    end

    it "prints uninstall's help" do
      Stdio.capture do |io|
        Package.run %w(uninstall --help)
        io.out.gets_to_end.should eq <<-EOS
          package remove [OPTIONS] PACKAGE_NAME

          Arguments:
            PACKAGE_NAME  specify package's name

          Options:
            -f          force to remove
            -h, --help  show this help\n
          EOS
      end
    end
  end
end
