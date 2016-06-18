require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    macro inherited
      def parse
        options.parse
      end
    end
  end
end
