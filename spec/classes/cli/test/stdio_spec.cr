require "../../../spec_helper"

describe Cli::Test::Stdio do
  it "captures stdout" do
    io, abc = Cli::Test::Stdio.capture do
      STDOUT.puts "output"
      STDERR.puts "error"
      "abc"
    end
    io.output.gets.should eq "output\n"
    io.error.gets.should eq "error\n"
    abc.should eq "abc"
  end
end
