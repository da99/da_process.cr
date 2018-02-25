

lib LibC
  fun dup(oldfd : LibC::Int) : LibC::Int
end

def io_capture(origin)
  begin
    o, i = IO.pipe
    dup = LibC.dup(origin.fd)
    origin.reopen(i)
    yield o
    LibC.dup2(dup, origin.fd)

  ensure
    o.close if o
    i.flush if i
    i.close if i
  end
end

