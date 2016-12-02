require "../spec_helper"
require "./bash_completion/class"

module CliWikiBashCompletionFeature
  it name do
    TicketToRide.generate_bash_completion.should eq File.read("#{__DIR__}/bash_completion/ticket-to-ride-bash-completion.sh").rstrip
  end
end
