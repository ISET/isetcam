function [scene, signalCube, rcSize] = sceneFluorescenceChart(odBloodLevels,weights,pSize,wave,targetLuminance)
% Create a fluorescence chart for testing
%
%   [scene, signalCube, rcSize] = ...
%      sceneFluorescenceChart(odBloodLevels,weights,[pSize],[wave],[targetLuminance])
%
% A fluorescence chart is created with blood variations down the rows and
% weight variations across the columns.
%
% Inputs
%  odBloodLevels   - Vector of blood optical density values (row dimension)
%  weights         - Matrix (nWeight x 5), one fluorophore-weight vector per column patch
%                    Order: [collagen1, FAD, porphyrin, chlorophyllA, keratin]
%  pSize           - Number of pixels on the side of each square patch (default 24)
%  wave            - Wavelength samples (default scene wave)
%  targetLuminance - Mean scene luminance in cd/m2 (default 100)
%
% Returns
%  scene       - Fluorescence chart as an ISETCam scene
%  signalCube  - Fluorescence signals sized [nBlood x nWeight x nWave]
%  rcSize      - [rows cols] = [nBlood nWeight]
%
% The chart parameters are attached to the scene and can be retrieved via
% sceneGet(scene,'chart parameters').
%
% See also: sceneReflectanceChart, sceneCreate
%

if ieNotDefined('odBloodLevels'), odBloodLevels = 2:12; end
if ieNotDefined('weights')
    weight1 = (7:20)';
    weights = [weight1, zeros(numel(weight1),4)];
end
if ieNotDefined('pSize'), pSize = 24; end
if ieNotDefined('targetLuminance'), targetLuminance = 100; end

odBloodLevels = odBloodLevels(:);
if ~ismatrix(weights) || isempty(weights)
    error('weights must be a non-empty 2D matrix sized [nWeight x nBasis].');
end

scene = sceneCreate('empty');
if ieNotDefined('wave')
    wave = sceneGet(scene,'wave');
else
    wave = wave(:);
    scene = sceneSet(scene,'wave',wave);
    scene = sceneSet(scene,'illuminant wave',wave);
end

nBlood = numel(odBloodLevels);
nWeight = size(weights,1);
nWave = numel(wave);
rcSize = [nBlood, nWeight];

if size(weights,2) ~= 5
    error('weights must have 5 columns (four basis fluorophores + keratin).');
end

% Load fluorescence basis and oxy-blood model once for efficiency.
fluorophoreNamesB = {'collagen1-smooth','FAD_webfluor','PorphyrinBjurshammar','chlorophyllA-7'};
[fixedFluorophores,wave] = fiLoadBasis(fluorophoreNamesB,'wave',wave);
oxyblood = medium('oxy_molarExtinctionCoefficient.mat', 'wave', wave);

% Keratin modeled as a skewed Gaussian.
mu0 = 425; sigma0 = 386; a0 = 5;
keratinBasis = normpdf((wave - mu0) / sigma0) .* (1 + normcdf(a0 * wave));
keratinBasis = keratinBasis(:);

% Final basis ordering:
%   1) collagen (blood-modulated), 2) FAD, 3) porphyrin, 4) chlorophyllA, 5) keratin
fixedFluorophores = cat(2,fixedFluorophores,keratinBasis);

weightsT = weights';
bloodBasis = fixedFluorophores(:,1);

signalCube = zeros(nBlood,nWeight,nWave);
rIdxMap = reshape(1:prod(rcSize),rcSize);

for rr = 1:nBlood
    oxyblood.opticalDensity = odBloodLevels(rr);
    oxyTransmittance = oxyblood.transmittance;

    finalFluorophores = fixedFluorophores;
    finalFluorophores(:,1) = bloodBasis .* oxyTransmittance;

    % signalMat is [nWave x nWeight]
    signalMat = finalFluorophores * weightsT;
    signalCube(rr,:,:) = reshape(signalMat',1,nWeight,nWave);
end

XYZ = ieXYZFromPhotons(signalCube,wave);

sData = imageIncreaseImageRGBSize(signalCube,pSize);
rIdxMap = imageIncreaseImageRGBSize(rIdxMap,pSize);

scene = sceneSet(scene,'photons',sData);

% Emissive chart; set a neutral illuminant bookkeeping field.
ee = ones(nWave,1);
illuminantPhotons = Energy2Quanta(wave,ee);
scene = sceneSet(scene,'illuminantPhotons',illuminantPhotons);
scene = sceneSet(scene,'illuminantComment','Fluorescence chart (emissive patches)');
scene = sceneSet(scene,'name','Fluorescence Chart');

scene = sceneAdjustLuminance(scene,targetLuminance);

chartP.odBloodLevels = odBloodLevels;
chartP.weights = weights;
chartP.pSize = pSize;
chartP.wave = wave;
chartP.targetLuminance = targetLuminance;
chartP.rowcol = rcSize;
chartP.rIdxMap = rIdxMap;
chartP.XYZ = XYZ;
chartP.signalCube = signalCube;
chartP.keratinParams = [mu0 sigma0 a0];

scene = sceneSet(scene,'chart parameters',chartP);

end
