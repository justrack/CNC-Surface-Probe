##########################################
# NOTE: This has only been tested on very specific gcode files
#       from a signle source.  There is no guarantee it will
#       work with any other files from any other source.
#
#    Make sure to change Min/Max/Setps below as needed to setup probing area
#
##########################################
import sys
import numpy
import serial
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from Tkinter import Tk
from tkFileDialog import askopenfilename
import re
import os
import time
from probe_util import twodinterp
from probe_util import cnc_comm_init


xMin = 0.25
xMax = 1.75
xSteps = 4

yMin = -2.75
yMax = -0.25
ySteps = 6

#check to make sure a valid file is picked first
Tk().withdraw() # we don't want a full GUI, so keep the root window from appearing
filename = askopenfilename(filetypes=[("G-code file","*.nc"),("Any File","*")],initialdir="/home/justin/Desktop/")
if filename == "" or filename == ():
  print("no file selected")
  sys.exit(0)

  
#setup serial and establish comms with linuxcnc
ser = serial.Serial('/dev/ttyUSB0', 19200)
s,c = cnc_comm_init()

#set to inches
c.mdi("G20")
if(c.wait_complete(10)!=1):
    sys.exit("linuxcnc command timeout")

#bring cnc to safe height    
c.mdi("G0Z0.5")
if(c.wait_complete(10)!=1):
    sys.exit("linuxcnc command timeout")



#define grid
x = numpy.linspace(xMin,xMax,xSteps)
y = numpy.linspace(yMin,yMax,ySteps)
X,Y = numpy.meshgrid(x,y)
Z = numpy.zeros((len(y),len(x)))

#setup plot
fig = plt.figure()
ax = Axes3D(fig)
plt.ion()
ax.plot_wireframe(X, Y, Z, rstride=1, cstride=1)
plt.show()
#loop through points
for j in range(len(y)):
    for i in range(len(x)):
        #send cnc to next probe point
        commandString="G0X{0:.4f}Y{1:.4f}".format(x[i],y[j])
        c.mdi(commandString)
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
        #send cnc down to probe hieght
        c.mdi("G0Z-0.1")
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
        
        #read out depth from probe
        time.sleep(0.4)
        ser.write('r')
        serial_output=ser.readline()
        Z[j][i] = float(serial_output)
        
        #update plot
        ax.clear()
        #ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.jet)
        ax.plot_wireframe(X, Y, Z, rstride=1, cstride=1)
        plt.draw()
        
        #send cnc up to safe height    
        c.mdi("G0Z0.1")
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
            
print Z
#plt.ioff()
#plt.show()

#initialization for interpolation
initalPointFound = False
curX = 0.0
curY = 0.0 
curZ = 0.0

#open output file
(root,ext) = os.path.splitext(filename)
outputPath = root + "_mod" + ext
outF = open(outputPath,'w')

#default to inches
unitFactor = 1

zeroZPauseInserted = False

with open(filename) as f:
  for line in f:
    
    #remove windowness (end of lines)
    line = re.sub("\r","",line)
    
    #make everything capital letters
    line = line.upper()

    #filter out comment lines
    match = re.search("(\(.*\))",line)
    if match:
      comment = match.group(1)
      line = re.sub("\(.*\)","",line)
    else:
      comment = "";
      
    #check for metric
    match = re.search("G21",line)
    if match:
      print("metric detected")
      unitFactor = 25.4
      
    originalLine = line
    onPoint = False
    while not onPoint:
      line = originalLine
      
      #find X,Y
      match = re.search("X([0-9.-]+).*Y([0-9.-]+)",line)
      if match:
        curX = float(match.group(1)) / unitFactor
        curY = float(match.group(2)) / unitFactor
        if not initalPointFound:
          oldX = curX
          oldY = curY
          if curX != 0.0 and curY != 0.0:
          initalPointFound = True
          #offset table such that this point is Z = 0
          z_out=twodinterp(x,y,Z,curX,curY)
          z = [[element1-z_out for element1 in element2] for element2 in Z]
          Z = z
      
        #Var Defs
        # curX/Y is final destination point
        # midX/Y is the next intermediate point
        # oldX/Y is the last intermediate point
        
        #calculate segment length
        segLen = ((curX-oldX)**2 + (curY-oldY)**2)**0.5
        if segLen <= 0.1:
          midX = curX
          midY = curY
          onPoint = True
        else:
          midX = oldX + (0.1)*(curX-oldX)/segLen
          midY = oldY + (0.1)*(curY-oldY)/segLen
          
        #modify X and Y part of line
        line = re.sub("X[0-9.-]+","X{0:.4f}".format(midX * unitFactor),line)
        line = re.sub("Y[0-9.-]+","Y{0:.4f}".format(midY * unitFactor),line)
          
        #ignore Z's before first point, map has not been normalized
        if initalPointFound:
        #is there a Z also in this line that needs to be modified  
        match = re.search("Z([0-9.-]+)",line)
        if match:
          oldZ = float(match.group(1)) / unitFactor
          curZ = oldZ
          z_out=twodinterp(x,y,Z,midX,midY)
          newZ = oldZ + z_out
          line = re.sub("Z[0-9.-]+","Z{0:.4f}".format(newZ * unitFactor),line)
        #if not add one after Y 
        else:
          z_out=twodinterp(x,y,Z,midX,midY)
          newZ = curZ + z_out
          line = re.sub("(Y[0-9.-]+)","\g<1> Z{0:.4f}".format(newZ * unitFactor),line)
            
        oldX = midX
        oldY = midY  
        
      #is there a Z by itself in this line that needs to be modified
      else:
        onPoint = True
        match = re.search("Z([0-9.-]+)",line)
        if match:
          oldZ = float(match.group(1)) / unitFactor
          curZ = oldZ
          #ignore Z's before first point, map has not been normalized
          if initalPointFound:
            z_out=twodinterp(x,y,Z,curX,curY)
            newZ = oldZ + z_out
            line = re.sub("Z[0-9.-]+","Z{0:.4f}".format(newZ * unitFactor),line)
            line = line +"G4 P0.5\n"

      #reinsert comment
      match = re.search("\n",line)
      if match:
        line = re.sub("\n",comment+"\n",line)
      else:
        line = line + comment

      #write out line to file
      outF.write(line)
      
      #insert zero Z pause if the time is right
      if initalPointFound and not zeroZPauseInserted:
        outF.write("( Zero Z Surface Here )\n")
        outF.write("M0\n")
        zeroZPauseInserted = True
    
#close output file
outF.close()

