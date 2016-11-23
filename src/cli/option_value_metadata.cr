module Cli
  class OptionValueMetadata(T) < Optarg::ValueMetadata(T)
    getter description : ::String?

    def initialize(desc)
      @description = desc
    end
  end
end
