module Cli
  abstract class Help
    alias Description = {head: ::String, body: ::Array(::String)}
    @__indent : ::Int32
    @__option_descriptions : {option: Array(Description), exit: Array(Description)}?
    @__options : ::String | ::Bool | ::Nil
    @__text : ::String?

    def initialize(indent = 2)
      @__indent = indent
    end

    def __option_descriptions
      @__option_descriptions ||= begin
        h = {
          option: [] of Description,
          exit: [] of Description
        }
        (__option_model.__options.values + __option_model.__handlers.values).each do |definition|
          head = definition.names.join(", ")
          varname = __variable_name_of(definition)
          head += " #{varname}" if varname
          head += " (multiple)" if [:string_array].includes?(definition.type)
          body = %w()
          desc = __description_of(definition)
          default = __default_of(definition)
          body += desc.split("\n") if desc
          body += default.split("\n") if default
          h[definition.metadata.help_type] << {head: head, body: body}
          if definition.type == :bool && definition.responds_to?(:not)
            unless definition.not.empty?
              head = definition.not.join(", ")
              desc = "disable #{definition.names.first}"
              h[definition.metadata.help_type] << {head: head, body: [desc]}
            end
          end
        end
        h
      end
    end

    def __variable_name_of(definition)
      md = definition.metadata
      case definition.type
      when :string, :string_array
        if md.responds_to?(:variable_name)
          md.variable_name
        end
      end
    end

    def __description_of(definition)
      md = definition.metadata
      if md.responds_to?(:description)
        md.description
      end
    end

    def __default_of(definition)
      md = definition.metadata
      if md.responds_to?(:default_string)
        case definition.type
        when :string, :string_array
          if s = md.default_string
            "(default: #{s})"
          end
        when :bool
          if md.default_string == "true"
            "(enabled as default)"
          end
        end
      end
    end

    def __options
      return nil if @__options == false
      descs = __option_descriptions[:option] + __option_descriptions[:exit]
      @__options = if descs.empty?
        @__options = false
        return nil
      else
        lines = ["Options:"]
        entries = %w()
        left_width = descs.map{|i| i[:head].size}.max + @__indent
        indent = " " * @__indent
        (self.class.__sort_description(__option_descriptions[:option]) + self.class.__sort_description(__option_descriptions[:exit])).each do |description|
          entry = %w()
          if description[:body].empty?
            entry << "#{indent}#{description[:head]}"
          else
            entry << "#{indent}#{description[:head].ljust(left_width)}#{description[:body][0]}"
          end
          if description[:body].size >= 2
            description[:body][1..-1].each do |i|
              entry << "#{indent}#{" " * left_width}#{i}"
            end
          end
          entries << entry.join("\n")
        end
        lines << entries.join("\n")
        lines.join("\n")
      end
    end

    def __text
      @__text ||= render
    end

    def self.__sort_description(description)
      description.sort do |a, b|
        a = __normalize_definition_name(a[:head])
        b = __normalize_definition_name(b[:head])
        n = a.downcase <=> b.downcase
        n == 0 ? __reverse_case(a) <=> __reverse_case(b) : n
      end
    end

    def self.__normalize_definition_name(name)
      name.split(/\=/)[0].sub(/^-*/, "")
    end

    def self.__reverse_case(s)
      s.split("").map{|i| i =~ /[A-Z]/ ? i.downcase : i.upcase}.join("")
    end

    private def __yield
      yield
    end

    def self.__caption
    end

    def self.__title
    end

    def self.__header
    end

    def self.__footer
    end

    def __caption
      self.class.__caption
    end

    def __title
      self.class.__title
    end

    def __header
      self.class.__header
    end

    def __footer
      self.class.__footer
    end

    macro caption(text = nil, &block)
      {% if text %}
        def self.__caption
          {{text}}
        end
      {% else %}
        def __caption
          __yield {{block}}
        end
      {% end %}
    end

    macro title(text = nil, &block)
      {% if text %}
        def self.__title
          {{text}}
        end
      {% else %}
        def __title
          __yield {{block}}
        end
      {% end %}
    end

    macro header(text = nil, &block)
      {% if text %}
        def self.__header
          {{text}}
        end
      {% else %}
        def __header
          __yield {{block}}
        end
      {% end %}
    end

    macro footer(text = nil, &block)
      {% if text %}
        def self.__footer
          {{text}}
        end
      {% else %}
        def __footer
          __yield {{block}}
        end
      {% end %}
    end
  end
end
