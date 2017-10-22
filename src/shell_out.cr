

def shell_out(raw_cmd, input : Nil | IO::Memory = nil)
  output = IO::Memory.new
  error  = IO::Memory.new
  cmd    = raw_cmd.split

  stat = Process.run(cmd.shift, cmd, output: output, error: error, input: input)

  if !stat.success? || !error.empty? || !stat.normal_exit? || stat.signal_exit?
    STDERR.puts error.rewind.to_s
    STDERR.puts output.rewind.to_s
    STDERR.puts "Exit code:   #{stat.exit_code}"
    STDERR.puts "Exit signal: #{stat.exit_signal}" if stat.signal_exit?
    Process.exit stat.exit_code
  end

  return output.rewind.to_s
end # === def shell_out

def shell_out?(raw_cmd : String)
  output = IO::Memory.new
  error  = IO::Memory.new
  cmd    = raw_cmd.split

  stat = Process.run(cmd.shift, cmd, output: output, error: error)

  if !stat.success? || !error.empty? || !stat.normal_exit? || stat.signal_exit?
    return false
  end

  return true
end # === def shell_out?
