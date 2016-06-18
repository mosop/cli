module Cli
  abstract class Help
    alias Description = {head: ::String, body: ::Array(::String)}
    @indent : ::Int32
    @option_descriptions : {option: Array(Description), exit: Array(Description)}?
    @options : ::String | ::Bool | ::Nil
    @text : ::String?

    def initialize(@indent = 2)
    end

    def option_descriptions
      @option_descriptions ||= begin
        h = {
          option: [] of Description,
          exit: [] of Description
        }
        (option_model.options.values + option_model.handlers.values).each do |definition|
          head = definition.names.join(", ")
          varname = __variable_name_of(definition)
          head += " #{varname}" if varname
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
      case definition.type
      when :string
        if definition.metadata.responds_to?(:variable_name)
          definition.metadata.variable_name
        end
      end
    end

    def __description_of(definition)
      if definition.metadata.responds_to?(:description)
        definition.metadata.description
      end
    end

    def __default_of(definition)
      case definition.type
      when :string
        if definition.metadata.responds_to?(:default_string)
          if s = definition.metadata.default_string
            "(default: #{s})"
          end
        end
      when :bool
        if definition.responds_to?(:default)
          if definition.default == true
            "(enabled as default)"
          end
        end
      end
    end

    def options
      return nil if @options == false
      descs = option_descriptions[:option] + option_descriptions[:exit]
      @options = if descs.empty?
        @options = false
        return nil
      else
        lines = ["Options:"]
        entries = %w()
        left_width = descs.map{|i| i[:head].size}.max + @indent
        indent = " " * @indent
        (self.class.sort_description(option_descriptions[:option]) + self.class.sort_description(option_descriptions[:exit])).each do |description|
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

    def text
      @text ||= render
    end

    def self.sort_description(description)
      description.sort do |a, b|
        a = normalize_definition_name(a[:head])
        b = normalize_definition_name(b[:head])
        n = a.downcase <=> b.downcase
        n == 0 ? reverse_case(a) <=> reverse_case(b) : n
      end
    end

    def self.normalize_definition_name(name)
      name.split(/\=/)[0].sub(/^-*/, "")
    end

    def self.reverse_case(s)
      s.split("").map{|i| i =~ /[A-Z]/ ? i.downcase : i.upcase}.join("")
    end

    private def __yield_block
      yield
    end

    def self.caption
    end

    def self.title
    end

    def self.header
    end

    def self.footer
    end

    def caption
      self.class.caption
    end

    def title
      self.class.title
    end

    def header
      self.class.header
    end

    def footer
      self.class.footer
    end

    macro caption(text = nil, &block)
      {% if text %}
        def self.caption
          {{text}}
        end
      {% else %}
        def caption
          __yield_block {{block}}
        end
      {% end %}
    end

    macro title(text = nil, &block)
      {% if text %}
        def self.title
          {{text}}
        end
      {% else %}
        def title
          __yield_block {{block}}
        end
      {% end %}
    end

    macro header(text = nil, &block)
      {% if text %}
        def self.header
          {{text}}
        end
      {% else %}
        def header
          __yield_block {{block}}
        end
      {% end %}
    end

    macro footer(text = nil, &block)
      {% if text %}
        def self.footer
          {{text}}
        end
      {% else %}
        def footer
          __yield_block {{block}}
        end
      {% end %}
    end
  end
end
