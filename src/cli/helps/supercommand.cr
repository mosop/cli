module Cli::Helps
  abstract class Supercommand < ::Cli::Help
    @subcommands_lines : ::Array(::Tuple(::String, ::String?))?
    @subcommands : (::String | ::Bool)?

    def subcommands_lines
      @subcommands_lines ||= begin
        a = [] of ::Tuple(::String, ::String?)
        command_model.subcommands.keys.sort.each do |name|
          subcommand = command_model.subcommands[name]
          name_column = name
          name_column += " (default)" if command_model.default_subcommand_name == name
          caption_column = if aliased = command_model.subcommand_aliases[name]?
            "alias for #{aliased}"
          else
            subcommand.help_model.caption
          end
          a << {name_column, caption_column}
        end
        a
      end
    end

    def subcommands
      return nil if @subcommands == false
      @subcommands = if subcommands_lines.empty?
        @subcommands = false
        return nil
      else
        lines = %w()
        lines << "Subcommands:"
        entries = %w()
        left_width = subcommands_lines.map{|i| i[0].size}.max + @indent
        indent = " " * @indent
        subcommands_lines.each do |line|
          l = if line[1]
            "#{indent}#{line[0].ljust(left_width)}#{line[1]}"
          else
            "#{indent}#{line[0]}"
          end
          lines << l
        end
        lines.join("\n")
      end
    end

    def render
      a = %w()
      s = nil
      a << s if s = self.title
      a << s if s = self.header
      a << s if s = self.subcommands
      a << s if s = self.options
      a << s if s = self.footer
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
