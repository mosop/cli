module Cli::Spec
  module Helper
    macro included
      extend ::Cli::Spec::Helper
    end

    def exit_command(output = nil, error = nil, code = nil)
      Expectation.new(output, error, code)
    end

    class Expectation
      alias Message = String | Regex

      getter! output : Message?
      getter! error : Message?
      getter! code : Int32?

      def initialize(@output, @error, @code)
      end

      def match(actual)
        case actual
        when Exit
          match_output(actual) && match_error(actual) && match_code(actual)
        else
          raise "The actual value must be Cli::Exit but #{actual.class.name}."
        end
      end

      def match_output(actual)
        output?.nil? || match_string(actual_output(actual), output)
      end

      def match_error(actual)
        error?.nil? || match_string(actual_error(actual), error)
      end

      def match_string(actual, expected)
        case expected
        when Regex
          expected =~ actual
        else
          actual == expected
        end
      end

      def match_code(actual)
        code?.nil? || actual.exit_code == code
      end

      def failure_message(actual)
        case actual
        when Exit
          return failure_message_for_output(actual) unless match_output(actual)
          return failure_message_for_error(actual) unless match_error(actual)
          return failure_message_for_code(actual) unless match_code(actual)
        end
        raise "Internal error."
      end

      def negative_failure_message(actual)
        case actual
        when Exit
          return negative_failure_message_for_output(actual) if match_output(actual)
          return negative_failure_message_for_error(actual) if match_error(actual)
          return negative_failure_message_for_code(actual) if match_code(actual)
        end
        raise "Internal error."
      end

      def failure_message_for_output(actual)
        <<-EOS
        Unmatched output.
          expected:#{indent(output, 4)}
          got:#{indent(actual_output(actual), 4)}
        EOS
      end

      def failure_message_for_error(actual)
        <<-EOS
        Unmatched error output.
          expected:#{indent(error, 4)}
          got:#{indent(actual_error(actual), 4)}
        EOS
      end

      def failure_message_for_code(actual)
        "Unmatched exit code: #{code} is expected but got #{actual.exit_code}."
      end

      def negative_failure_message_for_output(actual)
        <<-EOS
        Matched output.#{indent(output, 2)}
        EOS
      end

      def negative_failure_message_for_error(actual)
        <<-EOS
        Matched error output.#{indent(error, 2)}
        EOS
      end

      def negative_failure_message_for_code(actual)
        "Matched exit code: #{code}"
      end

      def actual_output(actual)
        actual.success? ? actual.message : nil
      end

      def actual_error(actual)
        actual.error? ? actual.message : nil
      end

      def indent(s, spaces)
        indent = " " * spaces
        s = s.to_s
        return "" if s.empty?
        "\n" + s.split("\n").map{|i| "#{indent}#{i}"}.join("\n")
      end
    end
  end
end
