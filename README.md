# ISETCam

Image systems engineering toolbox for cameras.  This is the core repository including many basic routines that are used by other ISET repositories.  This repository is necessary to run ISETBio.  It is already necessary for ISET3D, ISETAuto, ISETLens, and others.

Please see the [ISETCam wiki page](https://github.com/iset/isetcam/wiki) for more information.

This ISETCam distribution originated with a commercial product, ISET from Imageval. The ISETCam code and repositories have expanded significantly. For example, ISET software is closely integrated with physically based rendering and graphics (PBRT) in [ISET3D](https://github.com/ISET/iset3d/wiki). It is also closely connected to models the human visual encoding in [ISETBio](https://github.com/ISETBIO/ISETBio/wiki).

# Notes

### Software architecture

* May 28, 2024 - Please see the section on optics for an update on how ISETCam now relies on wavefront aberrations, represented by Zernike polynomials, to represent shift-invariant systems.  The new implementation also includes specifications of apertures with non-circular shapes, scratches, and dust particles.
* May 29, 2024 - The separation between ISETCam and ISETBio is complete. ISETBio now relies on the scene, optical image and certain other fundamental functions in ISETCam as a base library. Numerical validations have been moved into the ISETValidate repository, and these include separate ISETCam, ISETBio and ISET3d validations.  Extensive regression testing was performed to validate the new code against numerical calculations from the prior code.

### Models

* February 10, 2024 - We added a model for the split pixel sensor, specifically the Sony IMX490. These are based on the prior implementation of the Sony IMX363 sensor. A script, s_sensorIMX490 and related functions have been added. These methods simulate the split pixel capture and include some means for combining the large and small photodetector data.  The algorithms for combining continue to be developed.  A major point of this sensor is for the high dynamic range imaging, such as nighttime driving.  We added an ISET repository (ISETHdrsensor) that is exploring different HDR sensor technologies, including the split pixel.
* May 1, 2024 - New functions for creating controlled HDR images have been added (see sceneHDRImages).
* May 10, 2024 - First example implemented for running a PyTorch network, exported as an ONNX file, inside of Matlab using miniconda and pyenv.  See s_python.m

## Utilities

* May 10, 2024 We work more smoothly with EXR files, including sceneFromFile now reading in EXR files, and writing out sensor2EXR) This work was implemented for the extensions to HDR imaging and application of the Restormer PyTorch network for demosaicing sensor data.
* April 15, 2024 Implemented a remote copy function ieSCP, to help with the distributed nature of our assets and datafiles

