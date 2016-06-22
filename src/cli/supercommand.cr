require "./command_base"

module Cli
  abstract class Supercommand < ::Cli::CommandBase
    macro inherited
      {%
        if @type.superclass == ::Cli::Supercommand
          merge_of_subcommands = "@@self_subcommands"
          merge_of_subcommand_aliases = "@@self_subcommand_aliases"
        else
          merge_of_subcommands = "::#{@type.superclass.id}.subcommands.merge(@@self_subcommands)"
          merge_of_subcommand_aliases = "::#{@type.superclass.id}.subcommand_aliases.merge(@@self_subcommand_aliases)"
        end %}

      @@self_subcommands = {} of ::String => ::Cli::CommandBase.class
      @@subcommands = {} of ::String => ::Cli::CommandBase.class

      def self.subcommands
        @@subcommands = {{merge_of_subcommands.id}} if @@subcommands.empty?
        @@subcommands
      end

      @@self_subcommand_aliases = {} of ::String => ::String
      @@subcommand_aliases = {} of ::String => ::String

      def self.subcommand_aliases
        @@subcommand_aliases = {{merge_of_subcommand_aliases.id}} if @@subcommand_aliases.empty?
        @@subcommand_aliases
      end

      @@default_subcommand_name : ::String?

      def self.default_subcommand_name
        @@default_subcommand_name || super
      end

      def parse
        if @argv.empty?
          if self.class.default_subcommand?
            @subcommand_name = self.class.default_subcommand_name
            @subargv = \%w()
          else
            help!
          end
        elsif @argv[0].starts_with?("-")
          if self.class.default_subcommand?
            options.parse
          else
            @subcommand_name = self.class.default_subcommand_name
            @subargv = @argv[0..-1]
          end
        else
          raise ::Cli::UnknownCommand.new("#{self.class.global_name} #{@argv[0]}") unless self.class.subcommands.has_key?(@argv[0])
          @subcommand_name = @argv[0]
          @subargv = @argv.size >= 2 ? @argv[1..-1] : \%w()
        end
      end
    end

    @subargv = %w()

    macro command(name, default = false, aliased = nil)
      {%
        s = aliased || name
        a = s.strip.split(/\s+/)
        a = a.map{|i| name.split(/[_-]/).map{|j| i.capitalize}.join("")}
        class_name = "Commands::" + a.join("::Commands::")
      %}

      {% if default %}
        @@default_subcommand_name = {{name}}
      {% end %}

      @@self_subcommands[{{name}}] = {{class_name.id}}

      {% if aliased %}
        @@self_subcommand_aliases[{{name}}] = {{aliased}}
      {% end %}
    end

    def self.default_subcommand_name
    end

    def self.default_subcommand?
      !default_subcommand_name.nil?
    end

    @subcommand_name : ::String?

    def run
      if subcommand_name = @subcommand_name
        if subcommand = self.class.subcommands[@subcommand_name]?
          subcommand.new(self, @subargv).run
        end
      end
    end
  end
end
