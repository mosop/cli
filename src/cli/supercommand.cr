require "./command_base"

module Cli
  abstract class Supercommand < ::Cli::CommandBase
    macro inherited
      {%
        if @type.superclass == ::Cli::Supercommand
          merge_of_subcommands = "@@__self_subcommands"
          merge_of_subcommand_aliases = "@@__self_subcommand_aliases"
        else
          merge_of_subcommands = "::#{@type.superclass.id}.__subcommands.merge(@@__self_subcommands)"
          merge_of_subcommand_aliases = "::#{@type.superclass.id}.__subcommand_aliases.merge(@@__self_subcommand_aliases)"
        end %}

      @@__self_subcommands = {} of ::String => ::Cli::CommandBase.class
      @@__subcommands = {} of ::String => ::Cli::CommandBase.class

      def self.__subcommands
        @@__subcommands = {{merge_of_subcommands.id}} if @@__subcommands.empty?
        @@__subcommands
      end

      @@__self_subcommand_aliases = {} of ::String => ::String
      @@__subcommand_aliases = {} of ::String => ::String

      def self.__subcommand_aliases
        @@__subcommand_aliases = {{merge_of_subcommand_aliases.id}} if @@__subcommand_aliases.empty?
        @@__subcommand_aliases
      end

      @@__default_subcommand_name : ::String?

      def self.__default_subcommand_name
        @@__default_subcommand_name || super
      end

      def __parse
        if @__argv.empty?
          if self.class.__default_subcommand?
            @__subcommand_name = self.class.__default_subcommand_name
            @__subargv = \%w()
          else
            __help!
          end
        elsif @__argv[0].starts_with?("-")
          if self.class.__default_subcommand?
            options.__parse
          else
            @__subcommand_name = self.class.__default_subcommand_name
            @__subargv = @__argv[0..-1]
          end
        else
          raise ::Cli::UnknownCommand.new("#{self.class.__global_name} #{@__argv[0]}") unless self.class.__subcommands.has_key?(@__argv[0])
          @__subcommand_name = @__argv[0]
          @__subargv = @__argv.size >= 2 ? @__argv[1..-1] : \%w()
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
        @@__default_subcommand_name = {{name}}
      {% end %}

      @@__self_subcommands[{{name}}] = {{class_name.id}}

      {% if aliased %}
        @@__self_subcommand_aliases[{{name}}] = {{aliased}}
      {% end %}
    end

    def self.__default_subcommand_name
    end

    def self.__default_subcommand?
      !__default_subcommand_name.nil?
    end

    @__subargv = %w()
    @__subcommand_name : ::String?

    def run
      if subcommand_name = @__subcommand_name
        if subcommand = self.class.__subcommands[@__subcommand_name]?
          subcommand.new(self, @__subargv).__run
        end
      end
    end
  end
end
