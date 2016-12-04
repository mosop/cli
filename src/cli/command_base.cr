module Cli
  abstract class CommandBase
    macro inherited
      {% if @type.superclass != ::Cli::CommandBase %}
        {% if @type.superclass == ::Cli::Command %}
          {%
            is_command_root = true
            is_supercommand_root = false
            super_command_class = "Cli::CommandClass".id
            super_option_data = "Cli::OptionModel".id
            super_help = "Cli::Helps::Command".id
            super_help_class = "Cli::HelpClass".id
          %}
        {% elsif @type.superclass == ::Cli::Supercommand %}
          {%
            is_command_root = false
            is_supercommand_root = true
            super_command_class = "Cli::CommandClass".id
            super_option_data = "Cli::OptionModel".id
            super_help = "Cli::Helps::Supercommand".id
            super_help_class = "Cli::HelpClass".id
          %}
        {% else %}
          {%
            is_command_root = false
            is_supercommand_root = false
            super_command_class = "#{@type.superclass}::Class".id
            super_option_data = "#{@type.superclass}::Options".id
            super_help = "#{@type.superclass}::Help".id
            super_help_class = "#{@type.superclass}::Help::Class".id
          %}
        {% end %}

        class Class < ::{{super_command_class}}
          def self.instance
            @@instance.var ||= Class.new
          end

          def options
            Options::Class.instance
          end

          def help
            Help::Class.instance
          end

          def name
            ::StringInflection.kebab(command.name.split("::").last)
          end

          def command
            ::{{@type}}
          end

          def inherited_class?
            {% unless is_command_root || is_supercommand_root %}
              ::{{@type.superclass}}::Class.instance
            {% end %}
          end

          def supercommand?
            __get_supercommand
          end

          def abstract?
            {{@type.abstract?}}
          end

          if instance.supercommand? && !instance.abstract?
            instance.supercommand << instance
          end
        end

        def self.__klass
          @@__klass.var ||= Class.instance
        end

        class Options < ::{{super_option_data}}
          class Class
            {% if is_command_root || is_supercommand_root %}
              include ::Cli::OptionModel::Cli
            {% end %}

            def command
              ::{{@type}}::Class.instance
            end

            def default_definitions
              {% if is_supercommand_root %}
                [::{{@type}}.__klass.subcommand_option_model_definition] of ::Optarg::Definitions::Base
              {% else %}
                [] of ::Optarg::Definitions::Base
              {% end %}
            end

            def name
              {{@type.name.split("::")[-1].underscore}}
            end
          end

          def __command
            @__command.as(::{{@type}})
          end
        end

        class Help < ::{{super_help}}
          class Class < ::{{super_help_class}}
            def self.instance
              @@instance.var ||= Class.new
            end

            def command
              ::{{@type}}::Class.instance
            end
          end

          def self.__klass
            @@__klass.var ||= Class.instance
          end
        end

        def __option_data
          (@__option_data.var ||= Options.new(__argv, self)).as(Options)
        end

        def self.__new_help(indent = 2)
          Help.new(indent: indent)
        end

        {%
          names = @type.id.split("::")
          enclosing_class_name = names.size >= 3 ? names[0..-3].join("::").id : nil
        %}

        def self.__enclosing_class
          {% if enclosing_class_name %}
            ::{{enclosing_class_name}}
          {% end %}
        end

      {% end %}
    end

    def self.run(argv = %w())
      __run(argv)
    end

    @@__running = false

    def self.__run(argv)
      if @@__running
        __run_without_rescue(argv)
      else
        @@__running = true
        begin
          result = __run_with_rescue(argv)
        ensure
          @@__running = false
        end
      end
    end

    def self.__run_without_rescue(argv)
      new(nil, argv).__run
    end

    def self.__run_with_rescue(argv)
      new(nil, argv).__run
      0
    rescue ex : ::Cli::Exit
      out = ex.status == 0 ? ::STDOUT : ::STDERR
      out.puts ex.message if ex.message
      ex.status
    end

    @@__klass = Util::Var(CommandClass).new
    def __klass; self.class.__klass; end

    getter __parent : ::Cli::CommandBase?
    getter __argv : Array(String)

    def initialize(@__parent, @__argv)
      __rescue_parsing_error do
        __option_data.__parse
      end
    end

    @__option_data = Util::Var(Optarg::Model).new
    def option_data; __option_data; end

    def options; __options; end
    def __options; __option_data.__options; end

    def args; __args; end
    def __args; __option_data.__args; end

    def named_args; __named_args; end
    def __named_args; __option_data.__named_args; end

    def nameless_args; __nameless_args; end
    def __nameless_args; __option_data.__nameless_args; end

    def parsed_args; __parsed_args; end
    def __parsed_args; __option_data.__parsed_args; end

    def unparsed_args; __unparsed_args; end
    def __unparsed_args; __option_data.__unparsed_args; end

    def version; __version; end
    def __version; self.class.__klass.version; end

    def version?; __version?; end
    def __version?; self.class.__klass.version?; end

    def self.__help_on_parsing_error?
      true
    end

    macro command_name(value)
      class Class
        def name
          {{value}}
        end
      end
    end

    macro disable_help_on_parsing_error!
      def self.__help_on_parsing_error?
        false
      end
    end

    macro version(value)
      class Class
        def version?
          {{value}}
        end
      end
    end

    def help!(message = nil, error = nil, code = nil, indent = 2)
      __help! message, error, code, indent
    end

    def __help!(message = nil, error = nil, code = nil, indent = 2)
      error = !message.nil? if error.nil?
      __exit! message, error, code, true, indent
    end

    def exit!(message = nil, error = false, code = nil, help = false, indent = 2)
      __exit! message, error, code, help, indent
    end

    def __exit!(message = nil, error = false, code = nil, help = false, indent = 2)
      a = %w()
      a << message if message
      if help
        if help = self.class.__new_help(indent: indent).__text
          a << help
        end
      end
      message = a.join("\n\n") unless a.empty?
      code ||= error ? 1 : 0
      raise ::Cli::Exit.new(message, code)
    end

    def error!(message = nil, code = nil, help = false, indent = 2)
      __error! message, code, help, indent
    end

    def __error!(message = nil, code = nil, help = false, indent = 2)
      __exit! message, true, code, help, indent
    end

    def version!
      __version!
    end

    def __version!
      __exit! version
    end

    def run
      raise "Not implemented."
    end

    def __run
      run
    end

    def __rescue_parsing_error
      yield
    rescue ex : ::Optarg::ParsingError
      exit! "Parsing Error: #{ex.message}", error: true, help: self.class.__help_on_parsing_error?
    end

    def self.generate_bash_completion
      __klass.generate_bash_completion
    end
  end
end
