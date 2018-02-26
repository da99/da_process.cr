
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
      inotifywait("-r #{folder}", error: IO::Memory.new) do |change|
        files << change.file_name
      end
    }

    # === Wait for the watches to be set up.
    sleep 0.5

    File.touch(file("/a.txt"))

    # === Yield and wait for the
    #     `touch` event to be processed.
    sleep 0.3

    assert files.includes?("a.txt") == true
  end # === it "loops"
end # === desc "Inotify_Wait"
