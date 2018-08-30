# OpenEXR for Matlab

### Note
This is a modified mirror repository for the OpenEXR-Bindings from *HDRITools - High Dynamic Range Image Tools*. The original code is either incompatible or hard to compile with the latest versions of OpenEXR and mex, so we modified and cleaned-up their code to be hassle-free compatible with the latest versions of MATLAB, Xcode and the OpenEXR-Library. The bindings were tested with OSx 10.9+, MATLAB 2014a 8.3.0+, Xcode 5+ and OpenEXR 2.0.0+.

The original code can be obtained at [https://bitbucket.org/edgarv/hdritools/](https://bitbucket.org/edgarv/hdritools/). The original copyright remains to Jinwei Gu and Edgar Velazquez-Armendariz.

### What is it?
OpenEXR is a popular high dynamic range image fileformat mainly used by the film industry. This repository provides an interface for reading and writing OpenEXR files within MATLAB.

### Install
First, make sure you have setup up mex. Otherwise run
```matlab
mex -setup
```
inside of MATLAB.

Install the latest version of the OpenEXR-Library, e.g. via [Homebrew](http://brew.sh/)
```bash
brew install openexr
```

Run `make.m` inside of MATLAB to compile the bindings. If you install  OpenEXR without Homebrew make sure the paths inside of `make.m` point to your OpenEXR installation.

##### Ceveats
You may also need to update `~/.matlab/YOUR_MATLAB_VERSION/mexopts.sh` (e.g. in case you get a xcodebuild error, saying a SDK can not be located). Just change all occurances of e.g. `macosx10.8` to your version e.g. `macosx10.10` (3 occurances, comments excluded). If you are still getting errors, make sure you have the correct version of XCode installed or install the SDK for your system (http://www.mathworks.com/matlabcentral/answers/243868-mex-can-t-find-compiler-after-xcode-7-update-r2015b)

### Usage
##### exrread
	>> image = exrread('my_image.exr');
	>> size(image)
	ans =

	        1080        1920           3

	>> max(image(:))
	ans =

	    2.9297

	>> min(a(:))
	ans =

	    0.3069

##### exrwrite
	>> a = 100 * rand(300,300,3);
	>> size(a)
	ans =

	   300   300     3

	>> exrwrite(a, 'a.exr');
