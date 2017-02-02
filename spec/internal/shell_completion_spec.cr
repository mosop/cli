require "../spec_helper"
require "./shell_completion/class"

module CliInternalSpecs::ShellCompletion
  it name do
    dir = "#{__DIR__}/shell_completion/fixtures"
    zsh_dir = "#{dir}/zsh"
    Command.generate_bash_completion.should eq File.read("#{dir}/command.bash").chomp
    Command.generate_zsh_completion(functional: false).should eq File.read("#{dir}/command.zsh").chomp
    Command.generate_zsh_completion.should eq File.read("#{zsh_dir}/_command").chomp
  end
end
