module Cli::Helps
  abstract class Base
    TYPES = {
      :argument     => :argument,
      :array        => :option,
      :bool         => :option,
      :string       => :option,
      :string_array => :option,
      :handler      => :handler,
    }

    alias Description = {head: ::String, body: ::Array(::String)}

    @command : CommandClass
    @indent : ::Int32
    @definition_descriptions : {option: ::Array(Description), argument: ::Array(Description), handler: ::Array(Description)}?
    @arguments : ::String | ::Bool | ::Nil
    @options : ::String | ::Bool | ::Nil
    @text : ::String?

    def initialize(@command, indent = nil)
      @indent = indent || 2
    end

    def definition_descriptions
      @definition_descriptions ||= begin
        {
          argument: descriptions_for(@command.options.definitions.arguments),
          option:   descriptions_for(@command.options.definitions.value_options),
          handler:  descriptions_for(@command.options.definitions.handlers),
        }
      end
    end

    def descriptions_for(dfs)
      a = [] of Description
      dfs.each do |kv|
        df = kv[1]
        head = names_of(df)
        varname = variable_name_of(df)
        head += " #{varname}" if varname
        array_size = array_size_of(df)
        head += " (#{array_size})" if array_size
        body = %w()
        desc = description_of(df)
        default = default_of(df)
        inclusion = inclusion_of(df)
        body += desc.split("\n") if desc
        body += inclusion.split("\n") if inclusion
        body += default.split("\n") if default
        a << {head: head, body: body}
      end
      a
    end

    def names_of(df)
      case df
      when Optarg::DefinitionMixins::Argument
        df.metadata.display_name
      else
        df.names.join(", ")
      end
    end

    def variable_name_of(df)
      md = df.metadata
      case df
      when Optarg::Definitions::StringOption, Optarg::Definitions::StringArrayOption
        if md.responds_to?(:variable_name)
          md.variable_name
        end
      else
        # skip
      end
    end

    def description_of(df)
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

    def default_of(df)
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
          else
            # skip
          end
        else
          # skip
        end
      else
        # skip
      end
    end

    def array_size_of(df)
      case df
      when Optarg::DefinitionMixins::ArrayValue
        min = df.minimum_length_of_array
        min > 0 ? "at least #{min}" : "multiple"
      else
        # skip
      end
    end

    def inclusion_of(df)
      case df
      when Optarg::Definitions::StringOption
        if incl = df.validations.find { |i| i.is_a?(::Optarg::Definitions::StringOption::Validations::Inclusion) }
          inclusion_of2(incl.as(::Optarg::Definitions::StringOption::Validations::Inclusion))
        end
      when Optarg::Definitions::StringArgument
        if incl = df.validations.find { |i| i.is_a?(::Optarg::Definitions::StringArgument::Validations::Inclusion) }
          inclusion_of2(incl.as(::Optarg::Definitions::StringArgument::Validations::Inclusion))
        end
      else
        # skip
      end
    end

    def inclusion_of2(incl)
      a = incl.values.map do |v|
        desc = if md = v.metadata.as?(OptionValueMetadata(String))
                 md.description
               end
        Description.new(head: v.metadata.string, body: desc ? desc.split("\n") : %w())
      end
      indent = " " * @indent
      "one of:\n" + join_description2(a).to_s
    end

    def arguments
      return nil if @arguments == false
      if lines = join_description(:argument)
        @arguments = ["Arguments:", lines].join("\n")
      else
        @arguments = false
        nil
      end
    end

    def options
      return nil if @options == false
      if lines = join_description(:option, :handler)
        @options = ["Options:", lines].join("\n")
      else
        @options = false
        nil
      end
    end

    def join_description(*types)
      descs = [] of Description
      types.each { |t| descs += self.class.sort_description(definition_descriptions[t]) }
      return nil if descs.empty?
      join_description2 descs
    end

    def join_description2(descs)
      lines = %w()
      left_width = descs.map { |i| i[:head].size }.max + @indent
      indent = " " * @indent
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
      s.split("").map { |i| i =~ /[A-Z]/ ? i.downcase : i.upcase }.join("")
    end
  end
end
