require "../spec_helper"

module CliInternalDynamicValidationFeature
  include Cli::Spec::Helper

  class Command < Cli::Command
    class Options
      arg_array "name" do |definition|
        definition.on_validate do |context|
          context.validate_element_inclusion context.command.expected
        end
      end
    end

    def expected
      %w(foo bar baz)
    end
  end

  class Command2 < Cli::Command
    class Options
      arg_array "name" do |definition|
        definition.on_validate do |context|
          context.validate_element_inclusion context.command.expected2
        end
      end
    end

    def expected2
      %w(foo bar baz)
    end
  end

  it name do
    Command.run(%w(other)).should exit_command(error: /^Parsing Error: /)
    Command2.run(%w(other)).should exit_command(error: /^Parsing Error: /)
  end
end
