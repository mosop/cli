module Cli
  abstract class Help
    TYPES = {
      :argument => :argument,
      :array => :option,
      :bool => :option,
      :string => :option,
      :string_array => :option,
      :handler => :handler
    }

    alias Description = {head: ::String, body: ::Array(::String)}
    @__indent : ::Int32
    @__definition_descriptions : {option: ::Array(Description), argument: ::Array(Description), handler: ::Array(Description)}?
    @__arguments : ::String | ::Bool | ::Nil
    @__options : ::String | ::Bool | ::Nil
    @__text : ::String?

    def initialize(indent = 2)
      __command_class.__finalize_definition
      @__indent = indent
    end

    def __definition_descriptions
      @__definition_descriptions ||= begin
        {
          argument: __descriptions_for(__option_class.definitions.arguments),
          option: __descriptions_for(__option_class.definitions.options),
          handler: __descriptions_for(__option_class.definitions.handlers),
        }
      end
    end

    def __descriptions_for(dfs)
      a = [] of Description
      dfs.each do |kv|
        df = kv[1]
        head = __names_of(df)
        varname = __variable_name_of(df)
        head += " #{varname}" if varname
        array_size = __array_size_of(df)
        head += " (#{array_size})" if array_size
        body = %w()
        desc = __description_of(df)
        default = __default_of(df)
        inclusion = __inclusion_of(df)
        body += desc.split("\n") if desc
        body += inclusion.split("\n") if inclusion
        body += default.split("\n") if default
        a << {head: head, body: body}
        case df
        when Optarg::Definitions::BoolOption
          unless df.not.empty?
            head = df.not.join(", ")
            desc = "disable #{df.names.first}"
            a << {head: head, body: [desc]}
          end
        end
      end
      a
    end

    def __names_of(df)
      case df
      when Optarg::Definitions::Argument
        df.key.upcase
      else
        df.names.join(", ")
      end
    end

    def __variable_name_of(df)
      md = df.metadata
      case df
      when Optarg::Definitions::StringOption, Optarg::Definitions::StringArrayOption
        if md.responds_to?(:variable_name)
          md.variable_name
        end
      end
    end

    def __description_of(df)
      md = df.metadata
      if md.responds_to?(:description)
        md.description
      end
    end

    def __default_of(df)
      case df
      when Optarg::Definitions::Value
        case v = df.default_value.get?
        when String
          "(default: #{v})"
        when Array(String)
          "(default: #{v.join(", ")})"
        when Bool
          "(enabled as default)" if v
        end
      end
    end

    def __array_size_of(df)
      case df
      when Optarg::Definitions::ArrayOption
        min = df.minimum_length_of_array_value
        min > 0 ? "at least #{min}" : "multiple"
      end
    end

    def __inclusion_of(df)
      case df
      when Optarg::Definitions::StringOption
        if incl = df.value_validations.find{|i| i.is_a?(::Optarg::Definitions::StringOption::Validations::Inclusion)}
          __inclusion_of2(incl.as(::Optarg::Definitions::StringOption::Validations::Inclusion))
        end
      when Optarg::Definitions::StringArgument
        if incl = df.value_validations.find{|i| i.is_a?(::Optarg::Definitions::StringArgument::Validations::Inclusion)}
          __inclusion_of2(incl.as(::Optarg::Definitions::StringArgument::Validations::Inclusion))
        end
      end
    end

    def __inclusion_of2(incl)
      a = incl.values.map do |v|
        desc = if md = v.metadata.as?(OptionValueMetadata)
          md.description
        end
        Description.new(head: v.metadata.string, body: desc ? desc.split("\n") : %w())
      end
      indent = " " * @__indent
      "one of:\n" + __join_description2(a).to_s
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
      if lines = __join_description(:option, :handler)
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
      __join_description2 descs
    end

    def __join_description2(descs)
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
      @__text ||= __render
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
    def self.__caption; end;

    def __title; self.class.__title; end
    def self.__title; end

    def __header; self.class.__header; end
    def self.__header; end

    def __footer; self.class.__footer; end
    def self.__footer; end

    def __unparsed_args; self.class.__unparsed_args; end
    def self.__unparsed_args; end

    def self.local_name; __local_name; end
    def self.__local_name
      __command_class.__local_name
    end

    def self.global_name; __global_name; end
    def self.__global_name
      __command_class.__global_name
    end

    def __default_title; self.class.__default_title; end
    @@__default_title : String?
    def self.__default_title
      @@__default_title ||= begin
        a = %w()
        a << __global_name
        unless __option_class.definitions.options.empty?
          required = __option_class.definitions.options.any? do |kv|
            kv[1].value_required?
          end
          a << (required ? "OPTIONS" : "[OPTIONS]")
        end
        __option_class.definitions.arguments.each do |kv|
          required = kv[1].value_required?
          a << (required ? kv[1].metadata.display_name : "[#{kv[1].metadata.display_name}]")
        end
        if unparsed_args = __unparsed_args
          a << unparsed_args
        end
        a.join(" ")
      end
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

    macro unparsed_args(block)
      def self.__unparsed_args
        __yield do
          {{block}}
        end
      end
    end
  end
end
