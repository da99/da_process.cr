

def shell_out(raw_cmd)
  output = IO::Memory.new
  error  = IO::Memory.new
  cmd    = raw_cmd.split

  stat = Process.run(cmd.shift, cmd, output: output, error: error)

  if !stat.success? || !error.empty? || !stat.normal_exit? || stat.signal_exit?
    STDERR.puts error.rewind.to_s
    STDERR.puts output.rewind.to_s
    STDERR.puts stat.exit_code
    STDERR.puts stat.exit_signal if stat.signal_exit?
    Process.exit stat.exit_code
  end

  return output.rewind.to_s

end # === def shell_out

