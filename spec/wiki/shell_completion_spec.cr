require "../spec_helper"
require "./shell_completion/class"

module CliWikiShellCompletionFeature
  it name do
    dir = "#{__DIR__}/shell_completion/fixtures"
    zsh_dir = "#{dir}/zsh"
    TicketToRide.generate_bash_completion.should eq File.read("#{dir}/ticket-to-ride-completion.bash").rstrip
    TicketToRide.generate_zsh_completion(functional: false).should eq File.read("#{dir}/ticket-to-ride-completion.zsh").rstrip
    TicketToRide.generate_zsh_completion.should eq File.read("#{zsh_dir}/_ticket_to_ride").rstrip
  end
end
