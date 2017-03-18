require "../spec_helper"
require "./shell_completion/class"

module CliInternalSpecs::ShellCompletion
  extend HaveFiles::Spec::Dsl

  it name do
    Dir.tmp do |tmp|
      Dir.mkdir_p File.join(tmp, "zsh")
      File.write(File.join(tmp, "command.bash"), Command.generate_bash_completion + "\n")
      File.write(File.join(tmp, "command.zsh"), Command.generate_zsh_completion(functional: false) + "\n")
      File.write(File.join(tmp, "zsh", "_command"), Command.generate_zsh_completion + "\n")
      tmp.should have_files File.join(__DIR__, "shell_completion", "fixtures")
    end
  end
end
