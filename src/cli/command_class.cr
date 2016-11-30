module Cli
  abstract class CommandClass
    macro __get_supercommand
      {%
        name_components = @type.name.split("::")
      %}
      {% if name_components.size > 4 && name_components[-3] == "Commands" %}
        {%
          outer_module = name_components[0..-4].join("::").id
        %}
      {% else %}
        {%
          outer_module = nil
        %}
      {% end %}
      {% if outer_module %}
        __get_supercommand2(::{{outer_module}})
      {% else %}
        nil
      {% end %}
    end

    macro __get_supercommand2(type)
      {%
        type = type.resolve
      %}
      {% if type < ::Cli::Supercommand %}
        ::{{type}}::Class.instance
      {% else %}
        nil
      {% end %}
    end

    @@instance = Util::Var(CommandClass).new

    @subcommand_option_model_definition : OptionModel::Definitions::Subcommand?
    def subcommand_option_model_definition
      @@subcommand_option_model_definition ||= OptionModel::Definitions::Subcommand.new(self)
    end

    abstract def name : String
    abstract def options : OptionModel
    abstract def inherited_class? : Class?
    abstract def supercommand? : Class?

    def inherited_class
      inherited_class?.not_nil!
    end

    def supercommand
      supercommand?.not_nil!
    end

    getter subcommands = {} of String => CommandClass
    getter subcommand_values = [] of CommandClass
    property! default_subcommand_name : String?

    def initialize
      inherit
    end

    def inherit
      if inherited_class?
        inherited_class.subcommand_values.each do |cmd|
          self << cmd
        end
        @default_subcommand_name = inherited_class.default_subcommand_name?
      end
    end

    def <<(subcommand : CommandClass)
      subcommands[subcommand.name] = subcommand
      subcommand_values << subcommand
    end

    @version : String?
    def version?
    end

    def version
      @version ||= begin
        if v = version?
          v
        elsif supercommand?
          supercommand.version
        else
          raise "No version."
        end
      end
    end

    @global_name : String?
    def global_name
      @global_name ||= supercommand? ? "#{supercommand.global_name} #{name}" : name
    end

    def resolve_subcommand(name)
      name ||= default_subcommand_name?
      subcommands[name]?
    end

    def define_subcommand_alias(name, real)
      self << Alias.new(self, name, real)
    end

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
    end
  end
end
