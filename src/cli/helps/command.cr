module Cli::Helps
  abstract class Command < ::Cli::Help
    def render
      a = %w()
      s = nil
      a << s if s = self.__title
      a << s if s = self.__header
      a << s if s = self.__options
      a << s if s = self.__footer
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
