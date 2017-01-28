require "../spec_helper"

module CliFixes::Gh6
  module CliFixes
    module Gh6
      class Main < Cli::Supercommand
        class Help
          header "Main header"
          footer "Main footer"
        end
      end

      it name do
      end
    end
  end
end
