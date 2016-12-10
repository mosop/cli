require "./command_base"

module Cli
  abstract class Supercommand < ::Cli::CommandBase
    macro command(name, default = false, aliased = nil)
      {%
        s = aliased || name
        a = s.strip.split(" ")
        a = a.map{|i| i.split("-").join("_").split("_").map{|j| j.capitalize}.join("")}
      %}

      {% if default %}
        __klass.default_subcommand_name = {{name}}
        __klass.subcommand_option_model_definition.unrequire_value!
      {% end %}

      {% if aliased %}
        __klass.define_subcommand_alias {{name}}, {{aliased}}
      {% end %}
    end

    @__subcommand : CommandClass?
    def __subcommand?
      @__subcommand ||= __klass.resolve_subcommand(__named_args["subcommand"]?)
    end

    def __subcommand
      __subcommand?.not_nil!
    end

    def __run
      if __subcommand?
        __subcommand.run(self, __unparsed_args.dup)
      else
        __help!
      end
    end
  end
end
