module Cli
  abstract class CommandBase
    # :nodoc:
    macro __get_supercommand_class(type = nil)
      {%
        names = @type.name.split("::").map{|i| i.id}
      %}
      {% if names.size >= 3 %}
        __get_supercommand_class2 ::{{names[0..-2].join("::").id}}, ::{{names[0..-3].join("::").id}}
      {% elsif names.size >= 2 %}
        __get_supercommand_class2 ::{{names[0..-2].join("::").id}}
      {% else %}
        nil
      {% end %}
    end

    # :nodoc:
    macro __get_supercommand_class2(type1, type2 = nil)
      {% if type1.resolve < ::Cli::Supercommand %}
        {{type1}}.__klass
      {% elsif type2 && type2.resolve < ::Cli::Supercommand %}
        {{type2}}.__klass
      {% else %}
        nil
      {% end %}
    end
  end
end
