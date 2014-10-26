import sys
import numpy
import serial
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from Tkinter import Tk
from tkFileDialog import askopenfilename

from probe_util import cnc_comm_init


xMin = 0
xMax = 1.8
xSteps = 5

yMin = 0
yMax = 1.3
ySteps = 5


ser = serial.Serial('/dev/ttyUSB0', 19200)
s,c = cnc_comm_init()


    
c.mdi("G0Z0.5")
if(c.wait_complete(10)!=1):
    sys.exit("linuxcnc command timeout")



#define grid
x = numpy.linspace(xMin,xMax,xSteps)
y = numpy.linspace(yMin,yMax,ySteps)
X,Y = numpy.meshgrid(x,y)
Z = numpy.zeros((len(x),len(y)))

fig = plt.figure()
ax = Axes3D(fig)
plt.ion()
ax.plot_wireframe(X, Y, Z, rstride=1, cstride=1)
plt.show()
#loop through points
for j in range(len(y)):
    for i in range(len(x)):
        commandString="G0X{0:.4f}Y{1:.4f}".format(x[i],y[j])
        print(commandString)
        c.mdi(commandString)
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
        c.mdi("G0Z-0.1")
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
        
        ser.write('r')
        serial_output=ser.readline()
        print(serial_output)
        Z[j][i] = float(serial_output)
        ax.clear()
        #ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.jet)
        ax.plot_wireframe(X, Y, Z, rstride=1, cstride=1)
        plt.draw()
            
        c.mdi("G0Z0.1")
        if(c.wait_complete(10)!=1):
            sys.exit("linuxcnc command timeout")
            
print Z
plt.ioff()
plt.show()
