module Cli
  abstract class CommandClass
    Callback.enable
    define_callback_group :validate, proc_type: Proc(CommandBase, Nil)

    macro __get_supercommand(type = nil)
      {%
        type = type.resolve if type
        type = type || @type
        names = type.name.split("::").map{|i| i.id}
      %}
      {% if names.size >= 4 %}
        __get_supercommand2 ::{{names[0..-3].join("::").id}}, ::{{names[0..-4].join("::").id}}
      {% elsif names.size >= 3 %}
        __get_supercommand2 ::{{names[0..-3].join("::").id}}
      {% else %}
        nil
      {% end %}
    end

    macro __get_supercommand2(type1, type2 = nil)
      {% if type1.resolve < ::Cli::Supercommand %}
        {{type1}}::Class.instance
      {% elsif type2 && type2.resolve < ::Cli::Supercommand %}
        {{type2}}::Class.instance
      {% else %}
        nil
      {% end %}
    end

    @@instance = Util::Var(CommandClass).new

    @subcommand_option_model_definition : OptionModelDefinitions::Subcommand?
    def subcommand_option_model_definition
      @@subcommand_option_model_definition ||= OptionModelDefinitions::Subcommand.new(self)
    end

    abstract def name : String
    abstract def options : OptionModel
    abstract def inherited_class? : Class?
    abstract def supercommand? : Class?

    getter? helps_on_parsing_error = true

    def help_on_parsing_error!
      @helps_on_parsing_error = true
    end

    def disable_help_on_parsing_error!
      @helps_on_parsing_error = false
    end

    def inherited_class
      inherited_class?.not_nil!
    end

    def supercommand
      supercommand?.not_nil!
    end

    getter subcommands = {} of String => CommandClass
    getter subcommand_values = [] of CommandClass
    property! default_subcommand_name : String?

    def initialize
      inherit
    end

    def inherit
      if inherited_class?
        inherited_class.subcommand_values.each do |cmd|
          self << cmd
        end
        @default_subcommand_name = inherited_class.default_subcommand_name?
      end
    end

    def <<(subcommand : CommandClass)
      subcommands[subcommand.name] = subcommand
      subcommand_values << subcommand
    end

    @version : String?
    def version?
    end

    def version
      @version ||= begin
        if v = version?
          v
        elsif supercommand?
          supercommand.version
        else
          raise "No version."
        end
      end
    end

    @global_name : String?
    def global_name
      @global_name ||= supercommand? ? "#{supercommand.global_name} #{name}" : name
    end

    @snake_name : String?
    def snake_name
      @snake_name ||= StringInflection.snake(name)
    end

    def resolve_subcommand(name)
      name ||= default_subcommand_name?
      subcommands[name]?
    end

    def generate_bash_completion
      g = options.bash_completion.new_generator("_#{snake_name}")
      <<-EOS
      #{g.result}

      complete -F #{g.entry_point} #{name}
      EOS
    end

    def generate_zsh_completion(functional = nil)
      functional = true if functional.nil?
      g = options.zsh_completion.new_generator("_#{snake_name}")
      if functional
        <<-EOS
        #compdef #{name}

        #{g.result}
        EOS
      else
        <<-EOS
        #{g.result}

        compdef #{g.entry_point} #{name}
        EOS
      end
    end

    def define_subcommand_alias(name, real)
      self << Alias.new(self, name, real)
    end

    def rescue_error(command)
      yield
    rescue ex : ::Optarg::ParsingError
      command.exit! "Parsing Error: #{ex.message}", error: true, help: helps_on_parsing_error?
    end
  end
end
