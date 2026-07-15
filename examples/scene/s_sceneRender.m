%% Rendering a scene
%
% We show how to render a scene using different illuminants, and
% then we show how to render an HDR scene.
%
% Rendering here means mapping spectral radiance to displayable RGB.
% A typical sequence is:
%
% * adjust scene illuminant (if desired)
% * compute XYZ from spectral data
% * map XYZ to display RGB for visualization
%
% See also: hdrRender, sceneShowImage, sceneFromFile, scenePlot,
%           ieReadSpectra, sceneAdjustIlluminant, scenePlot
%
% Copyright ImagEval Consultants, LLC, 2012

%%
ieInit

%% Read in the scene
wList = [400:10:700];
fullFileName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(fullFileName ,'multispectral',[],[],wList);

% Have a look at the image (just mapping different spectral bands into rgb)
sceneWindow(scene);

% Plot the illuminant
scenePlot(scene,'illuminant photons roi')

%% Transform the current illuminant to daylight
% notice that daylight is defined only out to ~700 nm
% try to find a spectral power distribution for daylight out to 950 nm

% Read illuminant energy.
wave  = sceneGet(scene,'wave');
daylight = ieReadSpectra('D75.mat',wave);

% Adjust function.  In this case daylight is a vector of illuminant
% energies at each wavelength.
scene = sceneAdjustIlluminant(scene,daylight);
scene = sceneSet(scene,'illuminantComment','Daylight (D75) illuminant');

% Have a look
sceneWindow(scene);
scenePlot(scene,'illuminant photons roi')

%% HDR

%The FX-Window data
fname = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs.mat');
s = sceneFromFile(fname,'multispectral');
sceneWindow(s);

srgb = sceneShowImage(s,0);
res = hdrRender(srgb);
vcNewGraphWin; imagesc(res); axis image; axis off

%% Standard image

fname = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
s = sceneFromFile(fname,'multispectral');
srgb = sceneShowImage(s,0);

res = hdrRender(srgb);
vcNewGraphWin; imagesc(res); axis image; axis off

%%
