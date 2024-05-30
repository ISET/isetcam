# ISETCam

Image systems engineering toolbox for cameras.  This is the core repository including many basic routines that are used by other ISET repositories.  Shortly, say in August 2023, this repository will become necessary to run ISETBio.  It is already necessary for ISET3D, ISETAuto, ISETLens, and others.

Please see the [ISETCam wiki page](https://github.com/iset/isetcam/wiki) for more information.

This ISETCam distribution originated with the commercial product, ISET from Imageval. The ISETCam code and repositories that rely on this code have expanded significantly. For example, it is closely integrated with physically based rendering and graphics in [ISET3D](https://github.com/ISET/iset3d/wiki) and the modeling methods for the human visual encoding in [ISETBio](https://github.com/ISETBIO/ISETBio/wiki).

# Notes

### Software architecture

* May 28, 2024 - Please see the section on optics for an update on how ISETCam now calculates shift-invariant systems
* May 29, 2024 - The separation between ISETCam and ISETBio has been implemented.  There are no longer duplicate functions,  ISETBio now relies on ISETCam as a base library, and validations now rely on the independent ISETValidate repository.  See the ISETBio wiki page for an update on how we performed the validations and regression testing.

### Models

* February 10, 2024 - We added a model for the split pixel sensor, specifically the Sony IMX490.  A script, s_sensorIMX490 and related functions have been added. These methods simulate the split pixel capture and include some means for combining the large and small photodetector data.  The algorithms for combining continue to be developed.  A major point of this sensor is for the high dynamic range imaging, such as nighttime driving.  We added an ISET repository (ISETHdrsensor) that is exploring different HDR sensor technologies, including the split pixel.

