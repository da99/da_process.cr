
Reference:
==========

* 15 - SIGTERM - terminate whenever/soft kill, typically sends SIGHUP as well?


```crystal

  DA_Process.new("my_cmd", "my args".split) # output and error are different IO::Memory


  system("...", ...)
  status = $?
  DA_Process.success?(status)
  DA_Process.success!(status)
```
