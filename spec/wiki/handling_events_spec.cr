require "../spec_helper"

module CliWikiHandlingEventsFeature
  it name do
    {{ run("#{__DIR__}/handling_events/run").stringify }}.should eq ":(\n:(\n:)\n"
  end
end
