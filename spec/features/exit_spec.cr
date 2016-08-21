require "../spec_helper"

module CliExitFeature
  class Open < Cli::Command
    class Options
      arg "word"
    end

    def valid?
      args.word == "sesame"
    end

    def run
      if valid?
        exit! "Opened!"
      else
        error! "Not opened!"
      end
    end
  end

  describe name do
    it "exit" do
      code, out = Stdio.capture do |io|
        {Open.run(%w(sesame)), io.out.gets_to_end}
      end
      code.should eq 0
      out.should eq "Opened!\n"
    end

    it "error" do
      code, err = Stdio.capture do |io|
        {Open.run(%w(paprika)), io.err.gets_to_end}
      end
      code.should eq 1
      err.should eq "Not opened!\n"
    end
  end
end
