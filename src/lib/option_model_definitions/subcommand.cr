module Cli::OptionModelDefinitions
  class Subcommand < Optarg::Definitions::StringArgument
    alias Model = OptionModel

    getter command_class : CommandClass

    def initialize(@command_class)
      super "subcommand", metadata: OptionMetadata.new, stop: true, required: true
    end

    def subclassify(model)
      if model.responds_to?(:__cli_command)
        Subcommand.new(model.__cli_command.__klass)
      else
        self
      end
    end

    def completion_words(gen)
      command_class.subcommands.select{|k,v| v.completable?}.map{|i| i[0]}
    end

    def completion_next_models_by_value(gen)
      ({} of String => Optarg::ModelClass).tap do |h|
        command_class.subcommands.each do |k, v|
          next unless v.completable?
          h[k] = v.options
        end
      end
    end
  end
end
