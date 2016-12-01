

require "../spec_helper"

module CliWikiBashCompletionFeature
  class TicketToRide < Cli::Command
    class Options
      string "--by", any_of: %w(train plane taxi), default: "train"
      arg "for", any_of: %w(kyoto kanazawa kamakura)
    end
  end

  it name do
    TicketToRide.generate_bash_completion.should eq File.read("#{__DIR__}/bash_completion/ticket-to-ride-bash-completion.sh").rstrip
  end
end
