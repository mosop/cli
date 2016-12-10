class Cli::CommandClass
  class Alias < CommandClass
    getter? supercommand : CommandClass
    getter name : String
    getter real_name : String

    def initialize(@supercommand, @name, @real_name)
    end

    def real_command
      supercommand.subcommands[real_name]
    end

    def options
      real_command.options
    end

    def inherited_class?
      real_command.inherited_class?
    end

    def command
      real_command.command
    end

    def help
      real_command.help
    end

    def abstract?
      real_command.abstract?
    end
  end
end
