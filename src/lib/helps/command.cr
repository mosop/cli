module Cli::Helps
  class Command < Base
    def render
      a = %w()
      s = nil
      a << (@command.title? || @command.default_title)
      a << s if s = @command.header?
      a << s if s = arguments
      a << s if s = options
      a << s if s = @command.footer?
      a.join("\n\n")
    end
  end
end
