require "../spec_helper"

module CliInternalExplicitExitCallsStandardExitFeature
  it name do
    {{ run("#{__DIR__}/explicit_exit_calls_standard_exit/run").stringify }}.should eq ":) 99\n"
  end
end
