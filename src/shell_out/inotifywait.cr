

class Inotify_Wait

  # =============================================================================
  # Class
  # =============================================================================

  def self.loop(*args, &blok : Proc(Inotify_Wait, Change, Nil))
    i = new(*args, &blok)

    STDERR.puts "=== inotifywait #{i.cmd}"

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

  # =============================================================================
  # Instance
  # =============================================================================

  getter proc   : Process
  getter blok   : Proc(Inotify_Wait, Change, Nil)
  getter out_io : IO::Memory = IO::Memory.new
  getter cmd : String

  delegate :terminated?, to: @proc

  def initialize(@cmd : String = "-m -r ./ -e close_write", &@blok : Proc(Inotify_Wait, Change, Nil))
    @proc = Process.new(
      "inotifywait",
      @cmd.split,
      output: @out_io,
      error: STDERR
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
        change = Change.new(l)
        @blok.call self, change
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
    @is_different : Bool

    def initialize(line : String)
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


