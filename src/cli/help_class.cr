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
          if df = kv[1].as?(::Optarg::Definitions::StringArrayArgument)
            min = df.minimum_length_of_array
            if min > 0
              (1..min).each do |n|
                a << "#{df.metadata.display_name}#{n}"
              end
            end
            vargs = ((min + 1)..(min + 2)).map do |n|
              "#{df.metadata.display_name}#{n}"
            end
            a << "[" + vargs.join(" ") + "...]"
          elsif df = kv[1].as?(::Optarg::Definitions::StringArgument)
            required = df.value_required?
            a << (required ? df.metadata.display_name : "[#{df.metadata.display_name}]")
          end
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
