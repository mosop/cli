require "./command_base"

module Cli
  # The base of supercommand classes.
  abstract class Supercommand < CommandBase
    # Sets subcommand attributes.
    #
    # ### Parameters
    # * name (String) : a target subcommand name
    # * default (Bool) : if true, it makes the target subcommand a default subcommand.
    # * aliased (String) : makes the target subcommand an alias of the other subcommand that has the *aliased* name.
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

    # :nodoc:
    def run
      if subcommand = __klass.resolve_subcommand(__option_data[String]["subcommand"]?)
        subcommand.run(self, unparsed_args.dup)
      else
        help!
      end
    end
  end
end
