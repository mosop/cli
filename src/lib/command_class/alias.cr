class Cli::CommandClass
  class Alias < CommandClass
    getter real_name : String

    def initialize(@supercommand, @name, @real_name)
    end

    @real_command : CommandClass?
    def real_command
      @real_command ||= supercommand.subcommands[@real_name]
    end

    def inherited_class?
      real_command.inherited_class?
    end

    def abstract?
      real_command.abstract?
    end

    def options
      real_command.options
    end

    def command
      real_command.command
    end

    def help
      real_command.help
    end

    def run(previous, args)
      case cmd = real_command
      when Alias
      else
        cmd.run previous, args
      end
    end
  end
end
