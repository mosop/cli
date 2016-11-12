require "./command_base"

module Cli
  abstract class Supercommand < ::Cli::CommandBase
    macro inherited
      {%
        if @type.superclass == ::Cli::Supercommand
          is_root = true
        else
          is_root = false
        end %}

      @@__self_subcommands = {} of ::String => ::Cli::CommandBase.class
      @@__subcommands : ::Hash(::String, ::Cli::CommandBase.class)?
      def self.__subcommands
        @@__subcommands ||= begin
          {% if is_root %}
            h = {} of ::String => ::Cli::CommandBase.class
          {% else %}
            h = ::{{@type.superclass}}.__subcommands
          {% end %}
          h.merge(@@__self_subcommands)
        end
      end

      @@__self_subcommand_aliases = {} of ::String => ::String
      @@__subcommand_aliases : ::Hash(::String, ::String)?
      def self.__subcommand_aliases
        @@__subcommand_aliases ||= begin
          {% if is_root %}
            h = {} of ::String => ::String
          {% else %}
            h = ::{{@type.superclass}}.__subcommand_aliases
          {% end %}
          h.merge(@@__self_subcommand_aliases)
        end
      end

      @@__default_subcommand_name : ::String?
      def self.__default_subcommand_name
        {% if is_root %}
          @@__default_subcommand_name
        {% else %}
          @@__default_subcommand_name || super
        {% end %}
      end

      def self.__default_subcommand?
        __subcommands[__default_subcommand_name] if __default_subcommand_name
      end

      def self.__is_alias_command_name?(name)
        __subcommand_aliases.has_key?(name)
      end

      def __subcommand
        if command = __args.subcommand?
          self.class.__subcommands.fetch(command, nil)
        end
      end
    end

    macro command(name, default = false, aliased = nil)
      {%
        s = aliased || name
        a = s.strip.split(" ")
        a = a.map{|i| i.split("-").join("_").split("_").map{|j| j.capitalize}.join("")}
        class_name = "Commands::" + a.join("::Commands::")
      %}

      {% if default %}
        Options.__arguments["subcommand"].default = {{name}}
        @@__default_subcommand_name = {{name}}
      {% end %}

      @@__self_subcommands[{{name}}] = {{class_name.id}}

      {% if aliased %}
        @@__self_subcommand_aliases[{{name}}] = {{aliased}}
      {% end %}
    end

    def __initialize_options(argv)
      @__option_model = opts = __new_options(argv)
      __rescue_parsing_error do
        begin
          opts.__parse
        rescue ex : Optarg::RequiredArgumentError
          raise ex unless ex.argument.key == "subcommand"
        end
      end
    end

    def __run
      if command = __subcommand
        subargv = __unparsed_args.dup
        command.new(self, subargv).__run
      else
        __help!
      end
    end
  end
end
