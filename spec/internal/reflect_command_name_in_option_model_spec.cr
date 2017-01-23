require "../spec_helper"

module CliInternalReflectCommandNameInOptionModelFeature
  class Default < Cli::Command
  end

  class Specific < Cli::Command
    command_name "specific_name"
  end

  it name do
    Default.__klass.options.name.should eq "default"
    Specific.__klass.options.name.should eq "specific_name"
  end
end
