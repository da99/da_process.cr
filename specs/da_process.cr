
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

describe ".new" do
  it "runs the command" do
    p = DA_Process.new("uptime")
    assert p.stat.normal_exit? == true
  end # === it "runs the command"

  it "sets :success? == true if no error" do
    p = DA_Process.new("uptime")
    assert p.success? == true
  end # === it "sets :success? == true if no error"

  it "sets :error? == true if error" do
    p = DA_Process.new("sdfsd dfs")
    assert p.error? == true
  end # === it "sets :error? == true if error"

  it "records the output" do
    p = DA_Process.new("echo a b c")
    assert p.output.to_s == "a b c\n"
  end # === it "records the output"

  it "records the error output" do
    p = DA_Process.new("abd242 242")
    assert p.error.to_s[/execvp: No such file or directory/] == "execvp: No such file or directory"
  end # === it "records the error output"
end # === desc ".new"
