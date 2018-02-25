

lib LibC
  fun dup(oldfd : LibC::Int) : LibC::Int
end

def io_capture(origin)
  close_on_exec = origin.close_on_exec?
  begin
    o, i = IO.pipe
    dup = LibC.dup(origin.fd)
    origin.reopen(i)
    yield o
    LibC.dup2(dup, origin.fd)
    origin.close_on_exec = close_on_exec

  ensure
    o.close if o
    i.flush if i
    i.close if i
  end
end

