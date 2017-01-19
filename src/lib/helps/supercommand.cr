module Cli::Helps
  class Supercommand < Base
    @subcommands_lines : ::Array(::Tuple(::String, ::String?))?
    def subcommands_lines
      @subcommands_lines ||= begin
        a = [] of ::Tuple(::String, ::String?)
        @command.subcommands.keys.sort.each do |name|
          subcommand = @command.subcommands[name]
          name_column = name
          name_column += " (default)" if @command.default_subcommand_name? == name
          caption_column = if al = subcommand.as?(CommandClass::Alias)
            "alias for #{al.real_name}"
          else
            subcommand.caption?
          end
          a << {name_column, caption_column}
        end
        a
      end
    end

    @subcommands : (::String | ::Bool)?
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
      a << (@command.title? || @command.default_title)
      a << s if s = @command.header?
      a << s if s = subcommands
      a << s if s = options
      a << s if s = @command.footer?
      a.join("\n\n")
    end
  end
end
