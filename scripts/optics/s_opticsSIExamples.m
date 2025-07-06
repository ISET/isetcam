%% Shift-invariant optics examples
%
% This script illustrates how to create shift-invariant optics.
%
% It creates a point spread functions for each wavelength, and places them
% in an optics structure and then optical image (OI) structure.  We then
% calculate the effect of the PSF on a simple scene, displaying the result
% in an optical image window.
%
% The PSF is specified as a blur at the optical image plane, using
% different functions.  The wavelength dependency is also introduced.
%
% See also
%   siSynthetic, ieSaveSIDataFile

%%
ieInit

%% Create the scene

% First, we  create a checkerboard scene to blur.

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
wave  = sceneGet(scene,'wave');

% We make a small field of view so that we close up view of the details.
scene = sceneSet(scene,'fov',2);

sceneWindow(scene);

%% Example 1: Create a pillbox point spread function

% Point spread functions are small images.  There is one image for each
% wavelength. In this example, the spatial grid is 128 x 128 with samples
% spaced every 0.25 microns. Hence, the PSF image size is  128 * 0.25 = 32
% microns on a side.
%
% We create a point spread for each wavelength, 400:10:700. We write out
% a file that contains the point spread functions using ieSaveSIDataFile.

% We specify the point spread with respect to units on the optical image
% which is also a sensor surface.  The sampling here is enough for a 1
% micron pixel.
umPerSample = [0.5,0.5];                % Sample spacing

% Point spread is a little square in the middle of the image
h = zeros(128,128); h(48:79,48:79) = 1; h = h/sum(h(:));
psf = zeros(128,128,length(wave));
for ii=1:length(wave), psf(:,:,ii) = h; end     % PSF data

% Save the data
psfFile = fullfile(tempdir,'SI-pillbox');
ieSaveSIDataFile(psf,wave,umPerSample,psfFile);

%% Read the psf and copy it into the optics slot of the oi

% After you compute, use the menu Analyze | Optics | <>  in the oiWindow to
% plot various properties of the optics.
%
oi = oiCreate;
optics = siSynthetic('custom',oi,psfFile,[]);

% Attach the optics to the oi (optical image)
oi = oiSet(oi,'optics',optics);

% Setthe model to shift invariant
oi = oiSet(oi,'optics model','shiftInvariant');

% Apply the optics to the checkerboard scene.
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Pillbox');

% Add to the database and show the OI window
oiWindow(oi);

%% Example 2:  A sharpening filter

% Now, we build a difference of Gaussians that will sharpen the original image
% a little.  This is the psf.
%
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
%% Example 3: A circular Gaussian PSF that changes with wavelength

% The spread of the Gaussian increases with wavelength, so the long wavelength
% PSF is much blurrier than the short wavelength PSF.  Look for the color fringing
% in the oiWindow.
%
wave    = oiGet(oi,'wave');
psfType = 'gaussian';
waveSpread = (wave/wave(1)).^3;

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
waveSpread = (wave/wave(1)).^2;

% Make point spreads with a bivariate Gaussian.
% If sFactor < 1, then x (horizontal) is sharper.  
% If sFactor > 1, then y (vertical)   is sharper. 
sFactor = 1.5;  
xyRatio = sFactor*ones(1,length(wave));

% Now call the routine with these parameters
optics  = siSynthetic(psfType,oi,double(waveSpread),xyRatio);
oi      = oiSet(oi,'optics',optics);

% Here is the rest of the computation, as above
oi  = oiSet(oi,'optics model','shiftInvariant');
scene   = ieGetObject('scene');
oi      = oiCompute(oi,scene);

oi = oiSet(oi,'name','Chromatic Gaussian');
oiWindow(oi);

%% Show the PSF as a function of wavelength in a movie

oiPlot(oi,'psf',550)

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
%{
 imageMultiview('oi',1:4,1);
%}

%% End
