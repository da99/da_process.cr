

class Inotify_Wait

  # =============================================================================
  # Class
  # =============================================================================

  # =============================================================================
  # Instance
  # =============================================================================

  getter proc   : Process
  getter blok   : Proc(Change, Nil)
  getter out_io : IO::Memory = IO::Memory.new
  getter cmd : String

  delegate :terminated?, to: @proc

  def initialize(@cmd : String = "-m -r ./ -e close_write", error = nil, &@blok : Proc(Change, Nil))
    error = error || STDERR
    error.puts "=== inotifywait #{@cmd}"
    @proc = Process.new(
      "inotifywait",
      @cmd.split,
      output: @out_io,
      error: error
    )
  end

  def kill
    unless proc.terminated?
      puts "=== killing process: #{proc.pid}"
      proc.kill(Signal::INT)
    end
  end

  def exit_on_error
    stat = proc.wait
    if stat.normal_exit? && !stat.success?
      exit stat.exit_code
    end
    stat
  end

  def flush_remaining
    return if out_io.empty?
    out_io.rewind
    puts out_io.gets_to_end
  end

  def process_a_line
    change = nil
    if !out_io.empty?
      out_io.rewind
      out_io.each_line { |l|
        change = Change.new(self, l)
        @blok.call change
      }
    end

    out_io.clear
    change
  end # === def process_a_line

  struct Change

    CONTENT_HISTORY = {} of String => String

    getter dir        : String
    getter event_name : String
    getter file_name  : String
    getter full_path  : String
    getter content    : String
    getter process    : Inotify_Wait
    getter line       : String

    @is_different : Bool

    def initialize(@process, @line)
      pieces      = line.split
      if pieces.size != 3
        STDERR.puts line
        exit 1
      end
      @dir        = pieces.shift
      @event_name = pieces.shift
      @file_name  = pieces.shift
      @full_path  = File.join(@dir, @file_name)
      @content    = File.read(@full_path)
      @is_exists  = File.exists?(@full_path)
      @is_different = @content != CONTENT_HISTORY[@full_path]?
        CONTENT_HISTORY[@full_path] = @content
    end # === def initialize

    def exists?
      @is_exists
    end

    def different?
      @is_different
    end

  end # === struct Change

end # === class Inotify

def inotifywait(*args, **named_args, &blok : Proc(Inotify_Wait::Change, Nil))
  i = Inotify_Wait.new(*args, **named_args, &blok)

  Signal::INT.trap do
    i.kill unless i.terminated?
    Signal::INT.reset
  end

  while !i.terminated?
    i.process_a_line
    Fiber.yield
  end

  i.flush_remaining
  i.exit_on_error
end


