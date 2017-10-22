
require "../src/shell_out"
require "spec"

describe ":shell_out" do

  it "works" do
    shell_out("uptime")[" up "]?
      .should eq(" up ")
  end # === it "works"

end # === desc ":shell_out"

describe ":shell_out?" do
  it "works" do
    shell_out?("uptime")
      .should eq(true)
  end # === it "works"
end # === desc ":shell_out?"
