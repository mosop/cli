require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    macro inherited
      def parse
        options.__parse
      end
    end
  end
end
