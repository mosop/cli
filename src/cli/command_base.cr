module Cli
  abstract class CommandBase
    Callback.enable
    define_callback_group :initialize
    define_callback_group :exit, proc_type: Proc(Exit, Nil)

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
            (@@instance.var ||= Class.new).as(Class)
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

          def run(argv)
            run(argv) {}
          end

          def run(argv, &block : ::{{@type}} -> _)
            run nil, argv, &block
          end

          def run(previous, argv)
            run(previous, argv) {}
          end

          def run(previous, argv, &block : ::{{@type}} -> _)
            cmd = command.new(previous, argv)
            rescue_exit(cmd) do
              rescue_error(cmd) do
                begin
                  cmd.__option_data.__parse
                  result = cmd.__run
                  cmd.__io.close_writer unless previous
                  yield cmd
                  result
                ensure
                  cmd.__io.close_writer unless previous
                end
              end
            end
          end

          def rescue_exit(cmd)
            if cmd.__previous?
              yield
            else
              begin
                result = yield
                cmd.run_callbacks_for_exit(::Cli::Exit.new) {}
                result
              rescue ex : ::Cli::Exit
                if ::Cli.test?
                  cmd.run_callbacks_for_exit(ex) {}
                  ex
                else
                  cmd.run_callbacks_for_exit ex do
                    ex.stdout.puts ex.message if ex.message
                  end
                  exit ex.exit_code
                end
              end
            end
          end
        end

        def self.__klass
          (@@__klass.var ||= Class.instance).as(Class)
        end

        def self.run(argv = \%w(), &block : ::{{@type}} -> _)
          __klass.run argv, &block
        end

        class Options < ::{{super_option_data}}
          class Class
            include ::Cli::OptionModelMixin

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

          class DynamicDefinitionContext
            def command
              parser.data.__command
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

    @@__klass = Util::Var(CommandClass).new
    def __klass; self.class.__klass; end

    getter! __previous : ::Cli::CommandBase?
    getter __argv : Array(String)

    def initialize(argv)
      initialize nil, argv
    end

    def initialize(@__previous, @__argv)
      run_callbacks_for_initialize {}
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

    macro command_name(value)
      class Class
        def name
          {{value}}
        end
      end
    end

    macro disable_help_on_parsing_error!
      Class.instance.disable_help_on_parsing_error!
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

    def self.run(argv = %w())
      __klass.run argv
    end

    def run
      raise "Not implemented."
    end

    def __run
      run
    end

    def run(klass)
      __run klass, %w()
    end

    def run(klass, argv)
      __run klass, argv
    end

    def __run(klass, argv)
      klass.__klass.run self, argv
    end

    def self.generate_bash_completion
      __klass.generate_bash_completion
    end

    def self.generate_zsh_completion(functional = nil)
      __klass.generate_zsh_completion(functional)
    end

    @__io : IoHash?
    def __io
      @__io ||= (__previous? ? __previous.__io : Cli.new_default_io)
    end

    def __io=(value)
      @__io = value
    end

    def io
      __io
    end

    def io=(value)
      self.__io = value
    end

    def puts(*args)
      __io[:out].puts *args
    end

    def print(*args)
      __io[:out].print *args
    end

    def out
      __io[:out]
    end

    def err
      __io[:err]
    end
  end
end
