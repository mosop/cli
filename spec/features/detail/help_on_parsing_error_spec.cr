require "../../spec_helper"

module CliHelpOnParsingErrorFeatureDetail
  include Cli::Spec::Helper

  class Bookmark < ::Cli::Command
    class Options
      arg "url", required: true, desc: "a URL to be bookmarked"
    end
  end

  class Disabled < ::Cli::Command
    disable_help_on_parsing_error!
    class Options
      arg "url", required: true, desc: "a URL to be bookmarked"
    end
  end

  it name do
    Bookmark.run.should exit_command(error: <<-EOS
      Parsing Error: The URL argument is required.

      bookmark URL

      Arguments:
        URL  a URL to be bookmarked
      EOS
    )

    Disabled.run.should exit_command(error: <<-EOS
      Parsing Error: The URL argument is required.
      EOS
    )
  end
end
