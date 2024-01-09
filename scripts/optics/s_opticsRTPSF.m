%% The ray trace point spread function (PSF)
%
% The *ray trace* optics calculation is illustrated with a point
% array scene. The scene with a set of points is transformed to
% an optical image using ray trace methods based on the
% aspherical, 2mm lens computed in Zemax.
%
% The scene is also transformed using diffraction limited methods
% (shift-invariant).  The f# and focal length of the diffraction
% model are set equal to those of the ray trace lens.
%
% The illuminance computed the two ways is then compared.
%
% See also:  oiCompute, imageMultiview
%
% Copyright ImagEval Consultants, LLC, 2008

%%
ieInit

% To help the user, turn the wait bar on so they can see the
% calculation is progressing
wbStatus = ieSessionGet('waitbar');
ieSessionSet('waitbar','on');

%% Scene
scene = sceneCreate('pointArray',512,32);
scene = sceneInterpolateW(scene,450:100:650);
scene = sceneSet(scene,'hfov',10);
scene = sceneSet(scene,'name','psf Point Array');

sceneWindow(scene);

%% Optics
oi = oiCreate('ray trace');

% Load the example Zemax file
fname = fullfile(isetRootPath,'data','optics','rtZemaxExample.mat');
load(fname,'optics');

oi = oiSet(oi,'name','ray trace case');
oi = oiSet(oi,'optics',optics);

%% Compute
oi = oiSet(oi,'optics model','ray trace');
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','ray trace case');
oiWindow(oi);

%% Compute the diffraction limited case

oiDL = oiSet(oi,'name','diffraction case');
optics = oiGet(oiDL,'optics');
fNumber = opticsGet(optics,'rt fnumber');
optics = opticsSet(optics,'fnumber',fNumber*0.8);
oiDL = oiSet(oiDL,'optics',optics);

oiDL = oiSet(oiDL,'optics model','diffraction limited');
oiDL = oiCompute(oiDL,scene);
oiDL = oiSet(oiDL,'name','psf diffraction case');
oiWindow(oiDL);

%% Render the images
imageMultiview('oi',[1 2],1); truesize;

%% Reset the original wait bar status
ieSessionSet('waitbar',wbStatus);

%%

