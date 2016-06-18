module Cli::Helps
  abstract class Command < ::Cli::Help
    def render
      a = %w()
      s = nil
      a << s if s = self.title
      a << s if s = self.header
      a << s if s = self.options
      a << s if s = self.footer
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
