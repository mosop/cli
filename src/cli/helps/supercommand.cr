module Cli::Helps
  abstract class Supercommand < ::Cli::Help
    @__subcommands_lines : ::Array(::Tuple(::String, ::String?))?
    @__subcommands : (::String | ::Bool)?

    def __subcommands_lines
      @__subcommands_lines ||= begin
        a = [] of ::Tuple(::String, ::String?)
        __command_model.subcommands.keys.sort.each do |name|
          subcommand = __command_model.subcommands[name]
          name_column = name
          name_column += " (default)" if __command_model.default_subcommand_name? == name
          caption_column = if al = subcommand.as?(CommandClass::Alias)
            "alias for #{al.real_name}"
          else
            subcommand.help.caption?
          end
          a << {name_column, caption_column}
        end
        a
      end
    end

    def __subcommands
      return nil if @__subcommands == false
      @__subcommands = if __subcommands_lines.empty?
        @__subcommands = false
        return nil
      else
        lines = %w()
        lines << "Subcommands:"
        entries = %w()
        left_width = __subcommands_lines.map{|i| i[0].size}.max + @__indent
        indent = " " * @__indent
        __subcommands_lines.each do |line|
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

    def __render
      a = %w()
      s = nil
      a << (__klass.title? || __klass.default_title)
      a << __klass.header if __klass.header?
      a << s if s = __subcommands
      a << s if s = __options
      a << __klass.footer if __klass.footer?
      a.empty? ? nil : a.join("\n\n")
    end
  end
end
