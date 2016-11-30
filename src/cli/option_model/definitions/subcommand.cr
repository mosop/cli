module Cli::OptionModel::Definitions
  class Subcommand < Optarg::Definitions::StringArgument
    getter command_class : CommandClass

    def initialize(@command_class)
      super "subcommand", metadata: OptionMetadata.new, stop: true, required: true
    end

    def subclassify(model)
      Subcommand.new(model.as(CliClass).__cli_command)
    end

    def __command_class_of(model)
      if model.responds_to?(:command)
        model.command.as(CommandClass)
      end
    end

    def completion_words(gen)
      command_class.subcommands.keys
    end

    def completion_next_models_by_value(gen)
      ({} of String => Optarg::ModelClass).tap do |h|
        command_class.subcommands.each do |k, v|
          h[k] = v.options
        end
      end
    end
  end
end
