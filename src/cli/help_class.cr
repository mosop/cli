module Cli
  abstract class HelpClass
    @@instance = Util::Var(HelpClass).new

    @default_title : String?
    def default_title
      @default_title ||= begin
        a = %w()
        a << command.global_name
        unless options.definitions.options.empty?
          required = options.definitions.value_options.any? do |kv|
            kv[1].value_required?
          end
          a << (required ? "OPTIONS" : "[OPTIONS]")
        end
        options.definitions.arguments.each do |kv|
          required = kv[1].value_required?
          a << (required ? kv[1].metadata.display_name : "[#{kv[1].metadata.display_name}]")
        end
        if unparsed_args?
          a << unparsed_args
        end
        a.join(" ")
      end
    end

    def options
      command.options
    end

    def caption?; ; end
    def caption
      caption?.as(String)
    end

    def title?; ; end
    def title
      title?.as(String)
    end

    def header?; ; end
    def header
      header?.as(String)
    end

    def footer?; ; end
    def footer
      footer?.as(String)
    end

    def unparsed_args?; ; end
    def unparsed_args
      unparsed_args?.as(String)
    end
  end
end
