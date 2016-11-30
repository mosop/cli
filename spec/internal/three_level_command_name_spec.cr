require "../spec_helper"

module CliInternalThreeLevelCommandNameFeature
  class One < Cli::Supercommand
    command "two"

    module Commands
      class Two < Cli::Supercommand
        command "three"

        module Commands
          class Three < Cli::Supercommand
          end
        end
      end
    end
  end

  it name do
    One::Commands::Two::Commands::Three::Class.instance.global_name.should eq "one two three"
  end
end
