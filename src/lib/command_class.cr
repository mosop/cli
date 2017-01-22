module Cli
  # :nodoc:
  class CommandClass
    alias Runner = Proc(CommandBase, Array(String), Nil)
    @@runners = {} of String => Runner

    getter! class_name : String?
    property name : String
    getter! inherited_class : CommandClass?
    getter! supercommand : CommandClass?
    getter? helps_on_parsing_error = true
    getter subcommands = {} of String => CommandClass
    property! default_subcommand_name : String?
    setter version : String?
    property! caption : String?
    property! title : String?
    property! header : String?
    property! footer : String?
    property! unparsed_args : String?
    getter! options : Optarg::ModelClass?

    def initialize(@supercommand, @inherited_class, @class_name : String, @name, @abstract : Bool, @is_supercommand : Bool, @options : Optarg::ModelClass)
    end

    @abstract : Bool?
    def abstract?
      @abstract.not_nil!
    end

    @is_supercommand : Bool?
    def is_supercommand?
      @is_supercommand.not_nil!
    end

    def help_on_parsing_error!
      @helps_on_parsing_error = true
    end

    def disable_help_on_parsing_error!
      @helps_on_parsing_error = false
    end

    @subcommand_option_model_definition : OptionModelDefinitions::Subcommand?
    def subcommand_option_model_definition
      @subcommand_option_model_definition ||= OptionModelDefinitions::Subcommand.new(self)
    end

    @snake_name : String?
    def snake_name
      @snake_name ||= StringInflection.snake(@name)
    end

    # def initialize
    #   inherit
    # end
    #
    # def inherit
    #   if inherited_class?
    #     inherited_class.subcommand_values.each do |cmd|
    #       self << cmd
    #     end
    #     @default_subcommand_name = inherited_class.default_subcommand_name?
    #   end
    # end

    def <<(subcommand : CommandClass)
      subcommands[subcommand.name] = subcommand
    end

    def version?
      @version
    end

    def version
      @version ||= begin
        if v = @version
          v
        elsif sup = @supercommand
          sup.version
        else
          raise "No version."
        end
      end
    end

    @global_name : String?
    def global_name
      @global_name ||= if sup = @supercommand
        "#{sup.global_name} #{name}"
      else
        @name
      end
    end

    def run(previous, args)
      @@runners[class_name].call(previous, args)
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

    def generate_zsh_completion(functional)
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

    @default_title : String?
    def default_title
      @default_title ||= begin
        a = %w()
        a << global_name
        unless options.definitions.options.empty?
          required = options.definitions.value_options.any? do |kv|
            kv[1].value_required?
          end
          a << (required ? "OPTIONS" : "[OPTIONS]")
        end
        options.definitions.arguments.each do |kv|
          if df = kv[1].as?(::Optarg::Definitions::StringArrayArgument)
            min = df.minimum_length_of_array
            if min > 0
              (1..min).each do |n|
                a << "#{df.metadata.display_name}#{n}"
              end
            end
            vargs = ((min + 1)..(min + 2)).map do |n|
              "#{df.metadata.display_name}#{n}"
            end
            a << "[" + vargs.join(" ") + "...]"
          elsif df = kv[1].as?(::Optarg::Definitions::StringArgument)
            required = df.value_required?
            a << (required ? df.metadata.display_name : "[#{df.metadata.display_name}]")
          end
        end
        if unparsed_args?
          a << unparsed_args
        end
        a.join(" ")
      end
    end

    def new_help(indent)
      if @is_supercommand
        Helps::Supercommand.new(self, indent: indent)
      else
        Helps::Command.new(self, indent: indent)
      end
    end
  end
end

require "./command_class/*"
