%% Tutorial for Importing Optics from ZeMax into ISET
%
% This script describes the step-by-step process necessary to import and
% use optics from ZeMax.  Currently, this tutorial only covers importing 2D
% parameters that are output from ZeMax using the "ISET_RT_ZEMAX_2D.ZPL"
% macro.
%
% Before beginning this tutorial, please ensure that you have added all
% folders and files in the ISET package to the current workspace and that
% you have run the ISET_RT_ZEMAX_2D.ZPL macro in ZeMax.  Also, please make
% sure that the 'baseLensFileName' in the ISETPARMS.txt file identifies the
% lens of interest as being in the directory with all of the output ".dat"
% files that will be used for input into ISET.
%
% Please ensure that you have the following files in the proper directory:
% "ISETPARMS.txt" -- Contains Several Parameters About the Lens System
% "<LensName>_DI_.dat"  -- Contains Geometric Distortion Data
% "<LensName>_RI_.dat"  -- Contains Relative Illumination Data
% "<LensName>_CRA_.dat" -- Contains Chief Ray Angle Data
% "<LensName>_2D_PSF_Fld<FldHtIdx>_Wave<WavelengthIdx>.dat"
%   -- Contains the PSF Information at that Field Height and Wavelength;
%   these should be numbered sequentially (make sure none are missing).
%
% One thing to note: ISET treats anything ZeMax-related as "raytrace"
% optics, so the scripts designed to handle this data typically have "rt"
% as a prefix and are found in the "opticalimage/raytrace" directory.
%
% See also:  rtImportData, rtFileNames, opticsRayTrace, rtGeometry,
%            rtPrecomputePSF, rtPrecomputePSFApply
%
% Created by:  Travis Allen
% Created on:  12/11/2017

%% 1) Initialize ISET
ieInit

%% 2) Import Optics from ZeMax Files Into ISET Format (.mat)
%
% You should only have to run this section once. Afterward, you will simply
% select the ".mat" file that is output by this portion when creating your
% optics below.  Be sure to save the ".mat" file at the end of this import.
%
% Be sure that the "baseLensFileName" in the ISETPARMS.txt file points to
% the directory in which all of the ".dat" files reside, otherwise this
% portion will NOT work correctly.
oi = oiCreate();                %Need a generic oi to overwrite
optics = oiGet(oi,'optics');    %Need a generic optics to overwrite
isetParmsFile = vcSelectDataFile('stayput','r','txt',...
    'Select the ISETPARMS.txt file');
optics = rtImportData(optics, 'zemax', isetParmsFile);

%% 3) Create a Basic Scene & Display It
%
% Use a higher number of samples for better results (though the tradeoff is
% compute time). Also, use a larger FOV in order to incorporate more
% "eccentricity bands" (i.e. to utilize more of the PSF's sampled at
% various image heights)
%
% A word of caution:  the higher the FOV, the courser the sampling for the
% PSF's.  If the FOV is too large, you will not be able to get a satisfying
% outcome in the next section.  To offset this, you can increase the
% resolution of the scene image (originally set to 1028 here), but that
% will significantly increase the compute time.
scene = sceneCreate('grid lines', 512);
scene = sceneSet(scene,'fov',20);               % large FOV
scene = sceneSet(scene,'distance',10000000);    % not very important
sceneWindow(scene);

%% 4) Apply the "RayTrace" Optics and Show in an oiWindow
%
% Here you will select the ".mat" file that you output from step 2 above.
%
% The most time consuming portion of this section is the oiCompute() stage.
% This is where all of the PSF's are applied.  The higher the resolution of
% the scene, the longer it will take.  Also, the greater the FOV, the more
% "eccentricity bands" will need to be interpolated, which can also add
% time to the computation.
rtFileName = vcSelectDataFile('stayput','r','mat',...
    'Select the RT Optics .mat file');
oi = oiCreate('raytrace', rtFileName);
oi = oiCompute(oi,scene);
oiWindow(oi);

%% Try another scene

scene = sceneCreate('slanted edge',512);
scene = sceneSet(scene,'fov',15);               % large FOV
scene = sceneSet(scene,'distance',10000000);    % not very important
% sceneWindow(scene);
oi = oiCompute(oi,scene);
oiWindow(oi);
%% End of Tutorial
%
% You can now use these optics as you would any others in ISET.  You can go
% on to simulate the sensor, processor, and display, if you'd like.

%%