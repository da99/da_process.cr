
def shell_out(raw_cmd : String)
  cmd    = raw_cmd.split
  shell_out(cmd.shift, cmd)
end # === def shell_out

def shell_out(raw_cmd, args : Array(String), input : IO::Memory = IO::Memory.new)
  output = IO::Memory.new

  stat = Process.run(raw_cmd, args, output: output, error: output, input: input)

  if !stat.success? || !stat.normal_exit? || stat.signal_exit?
    STDERR.puts output.rewind.to_s
    STDERR.puts "Exit code:   #{stat.exit_code}"
    STDERR.puts "Exit signal: #{stat.exit_signal}" if stat.signal_exit?
    Process.exit stat.exit_code
  end

  return output.rewind.to_s
end # === def shell_out

def shell_out?(raw_cmd : String)
  output = IO::Memory.new
  cmd    = raw_cmd.split

  stat = Process.run(cmd.shift, cmd, output: output, error: output)

  if !stat.success? || !stat.normal_exit? || stat.signal_exit?
    return false
  end

  return true
end # === def shell_out?
