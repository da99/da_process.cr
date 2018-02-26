
describe ":output" do

  it "returns captured output" do
    assert DA_Process.output("uptime")[" up "]? == " up "
  end # === it "works"

end # === desc ":output"

describe ":output!" do
  it "returns captured output on exit 0" do
    assert DA_Process.output!("uptime")[" up "]? == " up "
  end # === it "works"
end # === desc ":output!"

describe ":success!" do

  it "returns value if exit was 0" do
    stat = Process.run("uptime")
    assert DA_Process.success!(stat) == stat
  end # === it "works"

  it "runs String argument as command" do
    assert DA_Process.success!("uptime", output: IO::Memory.new).exit_code == 0
  end # === it "runs String argument as command"

end # === desc ":success!"

describe ":success?" do

  it "returns true if process exited 0" do
    assert DA_Process.success?(Process.run "uptime") == true
  end # === it "works"

  it "returns false if process exited non-zero" do
    assert DA_Process.success?(Process.run "somethingsd132") == false
  end # === it "returns false if process exited non-zero"

end # === desc ":shell_out?"
