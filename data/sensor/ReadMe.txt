The different components of a sensor model are stored in the various folders.

The color filter array pattern options are in cfa.

Color filters are in colorfilters

IR filters are in irfilters

Photodetector spectral QE are in photodetectors

To load the individual components use 

	Sensor | Load "relevant component"

Entire models of a sensor (the ISET sensor data structure) are saved in this directory.  
To load these from the sensor window, you can use

	File | Load | Sensor (.mat)


The files in this directory are the combination of several filters, or sometimes sensor data structures.  
We should clarify which are which by putting them in different directories.


