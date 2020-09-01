%% Compressing hyperspectral data (hypercube)
%
% Hyperspectral scene data (also called *hypercube* (HC)) can be
% quite large.  The spectral functions in the data are typically
% smooth, and thus compressible.
%
% Here, we use a linear model calculated from the singular value
% decomposition (svd) of the raw data to define spectral basis
% functions. We represent the image photons with respect to these
% spectral bases.
%
% There are a number of functions that manage hyper-cube data.
% You can list these using
%
%    doc('hypercube')
%
% See also:  hcBasis, scenePlot, sceneFromFile,
%   ieSaveMultiSpectralImage, s_scene2ImageData,
%   s_scene2SampledScene, s_renderScene,
%
% Copyright ImagEval Consultants, LLC, 2012

%%
ieInit
delay = 0.2;

%% Read in the scene
fName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
scene = sceneFromFile(fName,'multispectral');

% Have a look at the image
sceneWindow(scene); pause(delay);

% Plot the illuminant
scenePlot(scene,'illuminant photons');

%% Compress the hypercube requiring only 95% of the var explained
vExplained = 0.95;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';
illuminant = sceneGet(scene,'illuminant');
oFile = fullfile(isetRootPath,'deleteMe.mat');
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);

% This poor representation produces a very desaturated
% image
sceneWindow(scene2); pause(delay);

%% Now require that much more of the variance be explained
vExplained = 0.99;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);
fprintf('Number of basis functions %.0f\n',size(imgBasis,2));

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);
sceneWindow(scene2); pause(delay)

%% Clean up the temporary file.
delete(oFile);

%% END
