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
          {% if @type.superclass == ::Cli::Supercommand %}
            arg "subcommand", required: true, stop: true
          {% end %}

          def command; __command; end
          def __command
            @__command as ::{{@type.id}}
          end
        end

        class Help < ::{{super_help.id}}
          def __command_model; self.class.__command_model; end
          def self.__command_model
            ::{{@type.id}}
          end

          def __option_model; self.class.__option_model; end
          def self.__option_model
            ::{{@type.id}}::Options
          end
        end

        def options; __options; end
        def __options
          @__options as Options
        end

        def self.__new_help(indent = 2)
          Help.new(indent: indent)
        end

        def self.__help_model
          Help
        end

        {%
          names = @type.id.split("::")
          enclosing_class_name = names.size >= 3 ? names[0..-3].join("::") : nil
        %}

        def self.__enclosing_class
          {% if enclosing_class_name %}
            ::{{enclosing_class_name.id}}
          {% end %}
        end

        def __new_options(argv)
          Options.new(self, argv)
        end
      {% end %}
    end

    def self.run(argv = %w())
      __run(argv)
    end

    @@__run = false

    def self.__run(argv)
      if @@__run
        __run_without_rescue(argv)
      else
        @@__run = true
        __run_with_rescue(argv)
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
    rescue ex : ::Optarg::ParsingError
      ::STDERR.puts "Parsing Error: #{ex.message}"
      1
    end

    getter __parent : ::Cli::CommandBase?

    def initialize(@__parent, argv)
      __initialize_options argv
    end

    @__options : ::Optarg::Model?
    def __options
      @__options as ::Optarg::Model
    end

    def args; __args; end
    def __args
      __options.__args
    end

    def unparsed_args; __unparsed_args; end
    def __unparsed_args
      __options.__unparsed_args
    end

    def self.__local_name
      ::StringInflection.kebab(name.split("::").last)
    end

    macro command_name(value)
      def self.__local_name
        {{value}}
      end
    end

    @@__global_name : String?
    def self.__global_name
      @@__global_name ||= begin
        if enclosing_class = __enclosing_class
          if enclosing_class.responds_to?(:__global_name)
            return "#{enclosing_class.__global_name} #{__local_name}"
          end
        end
        __local_name
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

    def run
      raise "Not implemented."
    end

    def __run
      run
    end
  end
end
