The different components of a sensor model are stored in the various folders.

* The color filter array information is data/sensor/colorfilters
* IR filters are in irfilters, though sometimes the CFA filters have an IR incorporated in them.
* Photodetector spectral QE are in photodetectors
* Sensors (with both CFA and pixels) are in data/sensor/* with the word sensor in the file name; the sub-directories auto and Nikon contain multiple sensors including pixel size, noise characteristics and such

From the GUI

To load the individual components use 

	Sensor | Load "relevant component"

Entire models of a sensor (the ISET sensor data structure) are saved in this directory.  
To load these from the sensor window, you can use

	File | Load | Sensor (.mat)


The files in this directory are the combination of several filters, or sometimes sensor data structures.  
We should clarify which are which by putting them in different directories.


