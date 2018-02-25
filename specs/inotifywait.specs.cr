
extend DA_SPEC

def folder(*args)
  File.join("tmp/in/files", *args)
end

def file(*args)
  File.join(folder, *args)
end

def reset_folder
  Dir.mkdir_p folder
  Dir.glob("#{folder}/*").each { |x|
    File.delete(x) if File.exists?(x)
    Dir.rmdir(x) if Dir.exists?(x)
  }
end


describe "Inotify_Wait" do

  it "loops" do
    reset_folder
    files = [] of String

    spawn {
      io_capture(STDERR) do |err_output|
        Inotify_Wait.loop("-r #{folder}") do |wait_proc, change|
          files << change.file_name
        end
      end
    }

    # === Wait for the watches to be set up.
    sleep 0.5

    File.touch(file("/a.txt"))

    # === Yield and wait for the
    #     `touch` event to be processed.
    sleep 0.2

    assert files.includes?("a.txt") == true
  end # === it "loops"
end # === desc "Inotify_Wait"
