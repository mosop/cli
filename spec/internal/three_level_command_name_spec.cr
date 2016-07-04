require "../spec_helper"

module Cli::Test::ThreeLevelCommandNameFeature
  class One < Cli::Supercommand
    command "two"

    module Commands
      class Two < Cli::Supercommand
        command "three"

        module Commands
          class Three < Cli::Supercommand
            class Help
              title global_name
            end
          end
        end
      end
    end
  end

  it "3-Level Command Name" do
    Stdio.capture do |io|
      One.run %w(two three)
      io.out.gets_to_end.should eq "one two three\n"
    end
  end
end
