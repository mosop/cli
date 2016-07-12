module Cli::Helps
  abstract class Command < ::Cli::Help
    def __render
      a = %w()
      s = nil
      a << (__title || __default_title)
      a << s if s = __header
      a << s if s = __arguments
      a << s if s = __options
      a << s if s = __footer
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
