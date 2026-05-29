function tests = test_sceneHCCompress()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
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
% Copyright ImagEval Consultants, LLC, 2012
%
% See also:  hcBasis, scenePlot, sceneFromFile,
%   ieSaveMultiSpectralImage, s_scene2ImageData,
%   s_scene2SampledScene, s_renderScene,
%

%%
ieInit
tolerance = 1e-6;

%% Read in the scene
fName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
scene = sceneFromFile(fName,'multispectral');

% Have a look at the image
% sceneWindow(scene);

% Plot the illuminant
% scenePlot(scene,'illuminant photons');

%% Compress the hypercube requiring only 95% of the var explained
vExplained = 0.95;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);
assert(abs(mean(imgBasis)/-0.148602519765920 - 1) < tolerance);

%% Save the data
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';
illuminant = sceneGet(scene,'illuminant');
oFile = fullfile(isetRootPath,'deleteMe.mat');
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);
m = sceneGet(scene2,'mean luminance');
assert(abs(m/31.219952376281693) - 1 < tolerance);

% This poor representation produces a very desaturated image
% sceneWindow(scene2);

%% Now require that much more of the variance be explained
vExplained = 0.99;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);
fprintf('Number of basis functions %.0f\n',size(imgBasis,2));
assert(size(imgBasis,2) == 3);

%% Save the data
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
m = double(illuminantGet(illuminant,'luminance'));
assert(abs(m/ 3.919852905273438e+02) - 1 < tolerance);

% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);
m = sceneGet(scene2,'mean luminance');
assert(abs(m/30.078709415522464) - 1 < tolerance);
% sceneWindow(scene2); 

%% Clean up the temporary file.
delete(oFile);

%% END

end
