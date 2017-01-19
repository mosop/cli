require "./command_base/macros"

module Cli
  abstract class CommandBase
    Callback.enable

    macro inherited
      {% if @type.superclass != ::Cli::CommandBase %}
        {%
          type_id = @type.name.split("(")[0].split("::").join("_").id
          snake_type_id = type_id.underscore
        %}
        {% if @type.superclass == ::Cli::Command %}
          {%
            is_command_root = true
            is_supercommand_root = false
            is_supercommand = false
            super_option_data = "Cli::OptionModel".id
          %}
        {% elsif @type.superclass == ::Cli::Supercommand %}
          {%
            is_command_root = false
            is_supercommand_root = true
            is_supercommand = true
            super_option_data = "Cli::OptionModel".id
          %}
        {% else %}
          {%
            is_command_root = false
            is_supercommand_root = false
            is_supercommand = @type < ::Cli::Supercommand
            super_option_data = "#{@type.superclass}::Options".id
          %}
        {% end %}

        {% if is_command_root || is_supercommand_root %}
          define_callback_group :initialize
          define_callback_group :exit, proc_type: Proc(::Cli::Exit, Nil)
        {% else %}
          inherit_callback_group :initialize
          inherit_callback_group :exit, proc_type: Proc(::Cli::Exit, Nil)
        {% end %}

        class Options < ::{{super_option_data}}
        end

        class ::Cli::CommandClass
          {% unless @type.abstract? %}
            # :nodoc:
            def {{snake_type_id}}__run(argv)
              {{snake_type_id}}__run(nil, argv)
            end

            # :nodoc:
            def {{snake_type_id}}__run(argv, &block : ::{{@type}} ->)
              {{snake_type_id}}__run(nil, argv, &block)
            end

            # :nodoc:
            def {{snake_type_id}}__run(previous, argv)
              {{snake_type_id}}__run(previous, argv) {}
            end

            # :nodoc:
            def {{snake_type_id}}__run(previous, argv, &block : ::{{@type}} ->)
              cmd = ::{{@type}}.new(previous, argv)
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

            # :nodoc:
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

            @@runners[{{@type.name.stringify}}] = Runner.new do |previous, args|
              ::{{@type}}.__klass.{{snake_type_id}}__run(previous, args)
            end
          {% end %}
        end

        @@__klass = ::Cli::CommandClass.new(
          supercommand: __get_supercommand_class,
          inherited_class: {{ is_command_root || is_supercommand_root ? nil : "::#{@type.superclass}.__klass".id }},
          class_name: {{@type.name.stringify}},
          name: ::StringInflection.kebab({{@type}}.name.split("::").last),
          is_supercommand: {{is_supercommand}},
          abstract: {{@type.abstract?}},
          options: Options.__klass
        )
        def self.klass; @@__klass; end
        def self.__klass; @@__klass; end
        def __klass; @@__klass; end

        {% unless @type.abstract? %}
          if @@__klass.supercommand?
            @@__klass.supercommand << @@__klass
          end

          def self.run
            __run
          end

          def self.__run
            __run(\%w())
          end

          def self.run(argv : Array(String))
            __run(argv)
          end

          def self.__run(argv : Array(String))
            __klass.{{snake_type_id}}__run(argv)
          end

          def self.run(previous : ::Cli::CommandBase, argv : Array(String) = \%w())
            __run(previous, argv)
          end

          def self.__run(previous : ::Cli::CommandBase, argv : Array(String) = \%w())
            __klass.{{snake_type_id}}__run(previous, argv)
          end

          def self.run(argv : Array(String) = \%w(), &block : ::{{@type}} ->)
            __run(argv, &block)
          end

          def self.__run(argv : Array(String) = \%w(), &block : ::{{@type}} ->)
            __klass.{{snake_type_id}}__run(argv, &block)
          end
        {% end %}

        class Options
          def self.__cli_command
            ::{{@type}}
          end

          def __cli_command
            @__cli_command.as(::{{@type}})
          end

          # class Class
          #   include ::Cli::OptionModelMixin
          #
          #   def command
          #     ::{{@type}}::Class.instance
          #   end
          #
          #   def default_definitions
          #     {% if is_supercommand_root %}
          #       [::{{@type}}.__klass.subcommand_option_model_definition] of ::Optarg::Definitions::Base
          #     {% else %}
          #       [] of ::Optarg::Definitions::Base
          #     {% end %}
          #   end
          #
          #   def name
          #     {{@type.name.split("::")[-1].underscore}}
          #   end
          # end
          #
          # class DynamicDefinitionContext
          #   def command
          #     parser.data.__command
          #   end
          # end
          #
          # def __command
          #   @__command.as(::{{@type}})
          # end
          {% if is_supercommand_root %}
            __definitions << ::{{@type}}.__klass.subcommand_option_model_definition
          {% end %}
        end

        class Help
          def self.caption(s)
            ::{{@type}}.__klass.caption = s
          end

          def self.title(s)
            ::{{@type}}.__klass.title = s
          end

          def self.header(s)
            ::{{@type}}.__klass.header = s
          end

          def self.footer(s)
            ::{{@type}}.__klass.footer = s
          end

          def self.unparsed_args(s)
            ::{{@type}}.__klass.unparsed_args = s
          end
        end

        def __option_data
          (@__option_data.var ||= Options.new(__argv, self)).as(Options)
        end

        # def self.__new_help(indent = 2)
        #   Help.new(indent: indent)
        # end
      {% end %}
    end

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
    def __options; __option_data; end

    def args; __args; end
    def __args; __option_data; end

    def named_args; __named_args; end
    def __named_args; __option_data.__named_args; end

    def nameless_args; __nameless_args; end
    def __nameless_args; __option_data.__nameless_args; end

    def parsed_args; __parsed_args; end
    def __parsed_args; __option_data.__parsed_args; end

    def unparsed_args; __unparsed_args; end
    def __unparsed_args; __option_data.__unparsed_args; end

    def version; __version; end
    def __version; __klass.version; end

    def version?; __version?; end
    def __version?; __klass.version?; end

    def self.command_name(value)
      __klass.name = value
    end

    def self.disable_help_on_parsing_error!
      __klass.disable_help_on_parsing_error!
    end

    def self.version(value)
      __klass.version = value
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
        a << __klass.new_help(indent: indent).text
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
