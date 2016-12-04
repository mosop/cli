require "../spec_helper"

module CliInternalArgArrayTitleFeature
  class Command < Cli::Command
    class Options
      arg_array "name"
    end
  end

  class WithMin < Cli::Command
    class Options
      arg_array "name", min: 3
    end
  end

  it name do
    Command::Help::Class.instance.default_title.should eq "command [NAME1 NAME2...]"
    WithMin::Help::Class.instance.default_title.should eq "with-min NAME1 NAME2 NAME3 [NAME4 NAME5...]"
  end
end
