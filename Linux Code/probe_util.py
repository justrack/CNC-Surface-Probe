import linuxcnc

def cnc_comm_init():
  s = linuxcnc.stat()
  c = linuxcnc.command()

  c.mode(linuxcnc.MODE_MDI)
  if(c.wait_complete()!=1):
    sys.exit("linuxcnc command timeout")
  return s,c

def test123(s,c):
  c.mode(linuxcnc.MODE_MDI)
  if(c.wait_complete()!=1):
    sys.exit("linuxcnc command timeout")
    
  c.mdi("G0Z0.5")
  if(c.wait_complete(10)!=1):
    sys.exit("linuxcnc command timeout")
