require "../spec_helper"

module Cli::Test::HelpOnParsingErrorFeature
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
    Stdio.capture do |io|
      Bookmark.run
      io.err.gets_to_end.should eq <<-EOS
        Parsing Error: The URL argument is required.

        bookmark URL

        Arguments:
          URL  a URL to be bookmarked\n
        EOS
    end

    Stdio.capture do |io|
      Disabled.run
      io.err.gets_to_end.should eq <<-EOS
        Parsing Error: The URL argument is required.\n
        EOS
    end
  end
end
