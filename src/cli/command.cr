require "./command_base"

module Cli
  abstract class Command < ::Cli::CommandBase
    macro inherited
      def __parse
        __options.__parse
      end
    end
  end
end
