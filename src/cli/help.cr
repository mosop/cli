module Cli
  abstract class Help
    alias Description = {head: ::String, body: ::Array(::String)}
    @__indent : ::Int32
    @__definition_descriptions : {option: ::Array(Description), argument: ::Array(Description), exit: ::Array(Description)}?
    @__arguments : ::String | ::Bool | ::Nil
    @__options : ::String | ::Bool | ::Nil
    @__text : ::String?

    def initialize(indent = 2)
      @__indent = indent
    end

    def __definition_descriptions
      @__definition_descriptions ||= begin
        h = {
          option: [] of Description,
          argument: [] of Description,
          exit: [] of Description
        }
        (__option_model.__options.values + __option_model.__arguments.values + __option_model.__handlers.values).each do |definition|
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

    def __arguments
      return nil if @__arguments == false
      if lines = __join_description(:argument)
        @__arguments = ["Arguments:", lines].join("\n")
      else
        @__arguments = false
        nil
      end
    end

    def __options
      return nil if @__options == false
      if lines = __join_description(:option, :exit)
        @__options = ["Options:", lines].join("\n")
      else
        @__options = false
        nil
      end
    end

    def __join_description(*types)
      descs = [] of Description
      types.each{|t| descs += self.class.__sort_description(__definition_descriptions[t])}
      return nil if descs.empty?
      lines = %w()
      left_width = descs.map{|i| i[:head].size}.max + @__indent
      indent = " " * @__indent
      descs.each do |desc|
        entry = %w()
        if desc[:body].empty?
          entry << "#{indent}#{desc[:head]}"
        else
          entry << "#{indent}#{desc[:head].ljust(left_width)}#{desc[:body][0]}"
        end
        if desc[:body].size >= 2
          desc[:body][1..-1].each do |i|
            entry << "#{indent}#{" " * left_width}#{i}"
          end
        end
        lines << entry.join("\n")
      end
      lines.empty? ? nil : lines.join("\n")
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

    def self.__yield
      yield
    end

    def __caption; self.class.__caption; end
    def self.__caption
    end

    def __title; self.class.__title; end
    def self.__title
    end

    def __header; self.class.__header; end
    def self.__header
    end

    def __footer; self.class.__footer; end
    def self.__footer
    end

    def self.local_name; __local_name; end
    def self.__local_name
      __command_model.__local_name
    end

    def self.global_name; __global_name; end
    def self.__global_name
      __command_model.__global_name
    end

    def self.argument_names(separator = " "); __argument_names(separator); end
    def self.__argument_names(separator = " ")
      __option_model.__arguments.keys.join(separator)
    end

    macro caption(block)
      def self.__caption
        __yield do
          {{block}}
        end
      end
    end

    macro title(block)
      def self.__title
        __yield do
          {{block}}
        end
      end
    end

    macro header(block)
      def self.__header
        __yield do
          {{block}}
        end
      end
    end

    macro footer(block)
      def self.__footer
        __yield do
          {{block}}
        end
      end
    end
  end
end
