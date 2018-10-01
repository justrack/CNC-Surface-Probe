import linuxcnc

def cnc_comm_init():
  s = linuxcnc.stat()
  c = linuxcnc.command()

  c.mode(linuxcnc.MODE_MDI)
  if(c.wait_complete()!=1):
    sys.exit("linuxcnc command timeout")
  return s,c

def twodinterp(x,y,z,xin,yin):
  x1=0
  for x_point in range(len(x)-1):
    if xin>x[x_point]:
      x1=x_point
  x2=x1+1
  
  y1=0
  for y_point in range(len(y)-1):
    if yin>y[y_point]:
      y1=y_point
  y2=y1+1

  x15y1=z[y1][x1] + (z[y1][x2] - z[y1][x1]) * (xin - x[x1]) / (x[x2] - x[x1])
  x15y2=z[y2][x1] + (z[y2][x2] - z[y2][x1]) * (xin - x[x1]) / (x[x2] - x[x1])
  z_val=x15y1 + (x15y2 - x15y1) * (yin - y[y1]) / (y[y2] - y[y1])
  
  return z_val

def test123(s,c):
  c.mode(linuxcnc.MODE_MDI)
  if(c.wait_complete()!=1):
    sys.exit("linuxcnc command timeout")
    
  c.mdi("G0Z0.5")
  if(c.wait_complete(10)!=1):
    sys.exit("linuxcnc command timeout")


