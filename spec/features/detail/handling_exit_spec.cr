require "../../spec_helper"

module CliHandlingExitFeatureDetail
  macro test(run, code = 0, out = "", err = "")
    class Exit%x < Cli::Command
      class Help
        title "title"
      end
      def run
        {{run.id}}
      end
    end
    it {{run}} do
      Stdio.capture do |io|
        Exit%x.run.should eq {{code}}
        io.out.gets_to_end.should eq {{out}}
        io.err.gets_to_end.should eq {{err}}
      end
    end
  end

  test %(exit!)
  test %(exit! "message"), out: "message\n"
  test %(exit! "message", error: true), err: "message\n", code: 1
  test %(exit! "message", code: 22), err: "message\n", code:22
  test %(error! "message"), err: "message\n", code: 1
  test %(error! "message", code: 22), err: "message\n", code: 22
  test %(help!), out: "title\n"
  test %(help! "message"), err: "message\n\ntitle\n", code: 1
  test %(help! "message", code: 22), err: "message\n\ntitle\n", code: 22
  test %(help! "message", error: false), out: "message\n\ntitle\n"
end
