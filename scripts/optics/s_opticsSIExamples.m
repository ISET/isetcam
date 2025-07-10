%% Shift-invariant optics examples
%
% This script demonstrates the creation of shift-invariant optics with
% custom point spread functions (PSFs).
%
% For each wavelength, PSFs are generated and incorporated into an optics
% structure, which is then embedded within an optical image (OI) structure.
%
% The script proceeds to calculate the impact of these PSFs on a simple
% scene, visualizing the outcome in an optical image window.
%
% PSFs are generated using `siSynthetic`, which supports various types and
% introduces wavelength-dependent chromatic aberrations. Read the
% siSynthetic function to learn how to create optics using a defined PSF.
%
% See also: 
%   siSynthetic, ieSaveSIDataFile

%%
ieInit

%% Create the scene

%{
pixPerCheck = 16;
nChecks = 6;
scene = sceneCreate('checkerboard',pixPerCheck,nChecks);
%}
% scene = sceneCreate('slanted edge');
% scene = sceneCreate('ringsrays');

imSize = [256 256];
spacing = 64;
thickness = 3;
scene = sceneCreate('grid lines',imSize,spacing,'ee',thickness);

% We make a small field of view so that we close up view of the details.
scene = sceneSet(scene,'fov',2);

sceneWindow(scene);

oi = oiCreate('psf');

%% Example 1: Create a pillbox point spread function

% The pillbox was often used in the past because it can be computed very
% quickly.  It isn't good for much, but I stuck it in here anyway.  Mostly,
% notice how much blurrier the pillbox is than an Airy pattern with the
% same disk size.

patchSize = airyDisk(700,oiGet(oi,'optics fnumber'),'units','mm');
optics    = siSynthetic('pillbox',oi , patchSize);

% Attach the optics to the oi (optical image)
oi = oiSet(oi,'optics',optics);

% Setthe model to shift invariant
% oi = oiSet(oi,'optics model','shiftInvariant');

% Apply the optics to the checkerboard scene.
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Pillbox');

% Add to the database and show the OI window
oiWindow(oi);

%% Example 2:  A wavelength-dependent Lorentizian

% The Lorentzian gamma parameter seems to run nicely from 1 to 10 or so on
% this support. Log spacing converts better to spread than linear spacing.
psfType    = 'lorentzian'; 
nWave      = oiGet(oi,'nwave');
gParameter = logspace(0,1,nWave);
optics     = siSynthetic(psfType,oi,gParameter);

oi = oiSet(oi,'optics',optics);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Wave dependent Lorentzian');
oiWindow(oi);
%  psfMovie(optics,ieNewGraphWin);

%% Example 3: A circular Gaussian PSF that changes with wavelength

% The spread of the Gaussian increases with wavelength, so the long wavelength
% PSF is much blurrier than the short wavelength PSF.  Look for the color fringing
% in the oiWindow.
%
wave    = oiGet(oi,'wave');
psfType = 'gaussian';
waveSpread = 0.5*(wave/wave(1)).^3;

% Make point spreads with a circular bivariate Gaussian
xyRatio = ones(1,length(wave));

% Now call the routine with these parameters
optics  = siSynthetic(psfType,oi,double(waveSpread),xyRatio);
oi      = oiSet(oi,'optics',optics);

% Here is the rest of the computation, as above
oi  = oiSet(oi,'optics model','shiftInvariant');
scene   = ieGetObject('scene');
oi      = oiCompute(oi,scene);

oi = oiSet(oi,'name','Chromatic Gaussian');
oiWindow(oi);
%% A shift invariant bivariate normal psf

% Notice that the checks appear a little wider than tall.  In the oiWindow,
% use
%
% * Analyze | Optics | PSF Mesh to see the point spread a different wavelengths
% * Analyze | Line x Wave Plot to see the loss of contrast a long wavelengths
% compared to short wavelengths

wave    = oiGet(oi,'wave');
psfType = 'gaussian';
waveSpread = 0.5*(wave/wave(1)).^3;

% Make point spreads with a bivariate Gaussian.
% If sFactor < 1, then x (horizontal) is sharper.  
% If sFactor > 1, then y (vertical)   is sharper. 
sFactor = 2;  
xyRatio = sFactor*ones(1,length(wave));

% Now call the routine with these parameters
optics  = siSynthetic(psfType,oi,double(waveSpread),xyRatio);
oi      = oiSet(oi,'optics',optics);

% Here is the rest of the computation, as above
oi  = oiSet(oi,'optics model','shiftInvariant');
scene   = ieGetObject('scene');
oi      = oiCompute(oi,scene);

oi = oiSet(oi,'name',sprintf('Chromatic Gaussian ratio %.1f',sFactor));
oiWindow(oi);

%% Show the PSF as a function of wavelength in a movie

oiPlot(oi,'psf',550);

% psfMovie(oiGet(oi,'optics'),ieFigure,0.1);


%% Compare a horizontal and vertical line

% Find the xy coordinates of the middle of the data
sz = oiGet(oi,'size');
[~,center] = getMiddleMatrix(oiGet(oi,'photons'),sz);
xyMiddle = center(1:2);

% Plot through the middle
vData = oiPlot(oi,' illuminance vline',xyMiddle,'nofigure');
hData = oiPlot(oi,' illuminance hline',xyMiddle,'nofigure');

ieFigure; 
plot(vData.pos,vData.data,'r-',hData.pos,hData.data,'b-');
grid on; xlabel('Position'); ylabel('Illuminance (lux)');
legend({'vertical','horizontal'});

%% Plot the spectral irradiance of a horizontal and a vertical line

%{
 oiPlot(oi,' irradiance hline',xy); colormap('jet');
%}

%% Compare multiple oi images

% This function lets you compare the image from all of the computed optical
% images.
%
% This example chooses the first 4 oi images
% {
 imageMultiview('oi',1:4,1);
%}

%% Sharpening

% Not physically realizable but used in image processing applications
%
% Now, we build a difference of Gaussians that will sharpen the original image
% a little.  This is the psf.
%
%{
h1 = fspecial('gaussian', 128, 5);
h2 = fspecial('gaussian', 128, 10);
h = h1 - 0.5*h2;
ieFigure; mesh(h)
psf = zeros(128,128,length(wave));
for ii=1:length(wave), psf(:,:,ii) = h; end     % PSF data

psfFile = fullfile(tempdir,'customFile');

% Save the data and all the rest, in compact form
ieSaveSIDataFile(psf,wave,umPerSample,psfFile);

optics = siSynthetic('custom',oi,psfFile,[]);
oi     = oiSet(oi,'optics',optics);
oi     = oiSet(oi,'optics model','shiftInvariant');

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Sharpened');
oiWindow(oi);
%}
%% End
