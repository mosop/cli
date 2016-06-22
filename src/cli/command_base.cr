module Cli
  abstract class CommandBase
    macro inherited
      {% if @type.superclass != ::Cli::CommandBase %}
        {%
          if @type.superclass == ::Cli::Command
            super_option_model = "Cli::OptionModel"
            super_help = "Cli::Helps::Command"
          elsif @type.superclass == ::Cli::Supercommand
            super_option_model = "Cli::OptionModel"
            super_help = "Cli::Helps::Supercommand"
          else
            super_option_model = "#{@type.superclass.id}::Options"
            super_help = "#{@type.superclass.id}::Help"
          end %}

        class Options < ::{{super_option_model.id}}
          def command
            @command as ::{{@type.id}}
          end
        end

        class Help < ::{{super_help.id}}
          def self.local_name
            ::{{@type.id}}.local_name
          end

          def self.global_name
            ::{{@type.id}}.global_name
          end

          def local_name
            ::{{@type.id}}.local_name
          end

          def global_name
            ::{{@type.id}}.global_name
          end

          def command_model
            ::{{@type.id}}
          end

          def option_model
            ::{{@type.id}}::Options
          end
        end

        def options
          @options as Options
        end

        def new_options
          Options.new(self, @argv)
        end

        def self.new_help(indent = 2)
          Help.new(indent: indent)
        end

        def self.help_model
          Help
        end

        def self.supercommand
          c = __expand_supercommand
          c if c.is_a?(::Cli::CommandBase.class)
        end
      {% end %}
    end

    macro __expand_supercommand
      {%
        names = @type.id.split("::")
        class_name = names.size >= 3 ? names[0..-3].join("::") : nil
      %}
      {{class_name.id}}
    end

    def self.run(argv = %w())
      new(nil, argv).run
    rescue ex : ::Cli::Exit
      out = ex.status == 0 ? ::STDOUT : ::STDERR
      out.puts ex.message if ex.message
      ex.status
    end

    @parent : ::Cli::CommandBase?
    @argv : ::Array(::String)
    @options : ::Optarg::Model?

    def initialize(@parent, @argv)
      @options = new_options
      parse
    end

    def args
      options.args
    end

    def unparsed_args
      options.unparsed_args
    end

    def self.local_name
      ::StringInflection.kebab(name.split("::").last)
    end

    macro command_name(value)
      def self.local_name
        {{value}}
      end
    end

    def self.global_name
      @@global_name ||= if supercommand = self.supercommand
        "#{supercommand.local_name} #{local_name}"
      else
        local_name
      end
    end

    def help!(indent = 2)
      raise ::Cli::Exit.new(self.class.new_help(indent: indent).text)
    end

    def run
      raise "Not implemented."
    end
  end
end
