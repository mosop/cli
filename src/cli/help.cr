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

    @@__klass = Util::Var(HelpClass).new
    def __klass; self.class.__klass; end

    def initialize(indent = 2)
      @__indent = indent
    end

    def __command_model
      __klass.command
    end

    def __option_model
      __klass.options
    end

    def __definition_descriptions
      @__definition_descriptions ||= begin
        {
          argument: __descriptions_for(__option_model.definitions.arguments),
          option: __descriptions_for(__option_model.definitions.value_options),
          handler: __descriptions_for(__option_model.definitions.handlers),
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
      end
      a
    end

    def __names_of(df)
      case df
      when Optarg::DefinitionMixins::Argument
        df.metadata.display_name
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
      case df
      when Optarg::Definitions::NotOption
        "disable #{df.bool.key}"
      else
        md = df.metadata
        if md.responds_to?(:description)
          md.description
        end
      end
    end

    def __default_of(df)
      case df
      when Optarg::DefinitionMixins::Value
        case v = df.default_value.get?
        when String
          "(default: #{v})"
        when Array(String)
          "(default: #{v.join(", ")})"
        when Bool
          case df
          when Optarg::Definitions::BoolOption
            "(enabled as default)" if v
          when Optarg::Definitions::NotOption
            "(disabled as default)" if v
          end
        end
      end
    end

    def __array_size_of(df)
      case df
      when Optarg::DefinitionMixins::ArrayValue
        min = df.minimum_length_of_array
        min > 0 ? "at least #{min}" : "multiple"
      end
    end

    def __inclusion_of(df)
      case df
      when Optarg::Definitions::StringOption
        if incl = df.validations.find{|i| i.is_a?(::Optarg::Definitions::StringOption::Validations::Inclusion)}
          __inclusion_of2(incl.as(::Optarg::Definitions::StringOption::Validations::Inclusion))
        end
      when Optarg::Definitions::StringArgument
        if incl = df.validations.find{|i| i.is_a?(::Optarg::Definitions::StringArgument::Validations::Inclusion)}
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

    macro caption(s = nil, &block)
      class Class
        def caption?
          {% if s %}
            {{s}}
          {% else %}
            {{block.body}}
          {% end %}
        end
      end
    end

    macro title(s = nil, &block)
      class Class
        def title?
          {% if s %}
            {{s}}
          {% else %}
            {{block.body}}
          {% end %}
        end
      end
    end

    macro header(s = nil, &block)
      class Class
        def header?
          {% if s %}
            {{s}}
          {% else %}
            {{block.body}}
          {% end %}
        end
      end
    end

    macro footer(s = nil, &block)
      class Class
        def footer?
          {% if s %}
            {{s}}
          {% else %}
            {{block.body}}
          {% end %}
        end
      end
    end

    macro unparsed_args(s = nil, &block)
      class Class
        def unparsed_args?
          {% if s %}
            {{s}}
          {% else %}
            {{block.body}}
          {% end %}
        end
      end
    end
  end
end
