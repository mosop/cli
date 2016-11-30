module Cli::Helps
  abstract class Command < ::Cli::Help
    def __render
      a = %w()
      s = nil
      a << (__klass.title? || __klass.default_title)
      a << __klass.header if __klass.header?
      a << s if s = __arguments
      a << s if s = __options
      a << __klass.footer if __klass.footer?
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
