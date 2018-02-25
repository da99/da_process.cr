
require "../src/shell_out"
require "inspect_bang"
require "da_spec"

extend DA_SPEC

describe ":shell_out (String, Array(String))" do

  it "works" do
    assert (shell_out("date", ["+%s"]) =~ /^\d+$/) == 0
  end # === it "works"

  it "exits 0 even if STDERR has content" do
    assert shell_out("bash specs/stderr.sh") == ("error\ndone\n")
  end # === it "exits 0 even if STDERR has content"

end # === desc ":shell_out"

describe ":shell_out (String)" do

  it "works" do
    assert shell_out("uptime")[" up "]? == " up "
  end # === it "works"

end # === desc ":shell_out"

describe ":shell_out?" do
  it "works" do
    assert shell_out?("uptime") == true
  end # === it "works"
end # === desc ":shell_out?"

require "./inotifywait.specs"
