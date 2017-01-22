require "./command_base/macros"

module Cli
  # The base of command classes.
  #
  # Your application should not directly inherit this class. Instead, use `Command` or `Supercommand`.
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
                    result = cmd.run
                    cmd.io.close_writer unless previous
                    yield cmd
                    result
                  ensure
                    cmd.io.close_writer unless previous
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
            run(\%w())
          end

          def self.run(argv : Array(String))
            klass.{{snake_type_id}}__run(argv)
          end

          def self.run(previous : ::Cli::CommandBase, argv : Array(String) = \%w())
            __klass.{{snake_type_id}}__run(previous, argv)
          end

          def self.run(argv : Array(String) = \%w(), &block : ::{{@type}} ->)
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

          {% if is_supercommand_root %}
            __klass.definitions << ::{{@type}}.__klass.subcommand_option_model_definition
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
          (@__option_data.var ||= Options.new(@__argv, self)).as(Options)
        end
      {% end %}
    end

    # :nodoc:
    getter? __previous : ::Cli::CommandBase?

    @__argv : Array(String)

    # :nodoc:
    def initialize(argv)
      initialize nil, argv
    end

    # :nodoc:
    def initialize(@__previous, @__argv)
      run_callbacks_for_initialize {}
    end

    @__option_data = Util::Var(Optarg::Model).new

    # Returns option and argument values (an `OptionModel` instance).
    #
    # This method is the same as `#args`.
    def options; __option_data; end

    # Returns option and argument values (an `OptionModel` instance).
    #
    # This method is the same as `#options`.
    def args; __option_data; end

    # Returns an array of nameless argument values.
    #
    # This method is a short form of `#args`.nameless_args.
    def nameless_args : Array(String)
      __option_data.nameless_args
    end

    # Returns an array of unparsed argument values.
    #
    # This method is a short form of `#args`.unparsed_args.
    def unparsed_args : Array(String)
      __option_data.unparsed_args
    end

    # Returns the command version.
    def version : String
      __klass.version
    end

    # Returns the command version.
    #
    # Returns nil, if no version is set.
    def version? : String?
      __klass.version?
    end

    # Sets the command name.
    def self.command_name(value : String)
      __klass.name = value
    end

    # Disables printing a help message when a parsing error occurs.
    def self.disable_help_on_parsing_error!
      __klass.disable_help_on_parsing_error!
    end

    # Sets the command version.
    def self.version(value : String)
      __klass.version = value
    end

    # Prints a help message and exits the command.
    def help!(message : String? = nil, error : Bool? = nil, code : Int32? = nil, indent = 2)
      error = !message.nil? if error.nil?
      exit! message, error, code, true, indent
    end

    # Exits the command.
    def exit!(message : String? = nil, error : Bool = false, code : Int32? = nil, help = false, indent = 2)
      a = %w()
      a << message if message
      if help
        a << __klass.new_help(indent: indent).text
      end
      message = a.join("\n\n") unless a.empty?
      code ||= error ? 1 : 0
      raise ::Cli::Exit.new(message, code)
    end

    # Exits the command with an error status.
    def error!(message : String? = nil, code : Int32? = nil, help : Bool = false, indent = 2)
      exit! message, true, code, help, indent
    end

    # Prints a version string and exits the command.
    def version!
      exit! version
    end

    # Runs the command.
    #
    # This method is an entrypoint for running a command.
    #
    # Subclasses must override this method.
    def run
      raise "Not implemented."
    end

    # Generates a bash completion script.
    def self.generate_bash_completion
      __klass.generate_bash_completion
    end

    # Generates a zsh completion script.
    def self.generate_zsh_completion(functional : Bool = true)
      __klass.generate_zsh_completion(functional)
    end

    @io : IoHash?
    # Returns a named IO container.
    def io
      @io ||= if prev = @__previous
        prev.io
      else
        Cli.new_default_io
      end
    end

    # Invokes the :out IO's puts method.
    def puts(*args)
      io[:out].puts *args
    end

    # Invokes the :out IO'S print method.
    def print(*args)
      io[:out].print *args
    end

    # Returns the :out IO.
    def out
      io[:out]
    end

    # Returns the :err IO.
    def err
      io[:err]
    end
  end
end
