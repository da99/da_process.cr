
require "./da_process/*"

module DA_Process

  extend self

  private def capture_output_and_error(cmd : String)
    args = cmd.split
    io = IO::Memory.new
    stat = Process.run(args.shift, args, output: io, error: io)
    io.rewind
    { io.to_s, stat }
  end

  def output(cmd : String)
    capture_output_and_error(cmd).first
  end

  def output!(cmd : String)
    pair = capture_output_and_error(cmd)
    stat = pair.last
    success! stat
    pair.first
  end

  def success?(stat)
    is_fail = !stat.success? || !stat.normal_exit? || stat.signal_exit?
    !is_fail
  end

  def success!(stat)
    if !success?(stat)
      STDERR.puts "Exit signal: #{stat.exit_signal}" if stat.signal_exit?
      Process.exit stat.exit_code
    end
    stat
  end

end # === module DA_Process
