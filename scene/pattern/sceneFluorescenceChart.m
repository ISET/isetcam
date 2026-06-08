function [scene, signalCube, rcSize] = sceneFluorescenceChart(odBloodLevels,weights,pSize,wave,targetLuminance,varargin)
% Create a fluorescence chart for testing
%
%   [scene, signalCube, rcSize] = ...
%      sceneFluorescenceChart(odBloodLevels,weights,[pSize],[wave],[targetLuminance],[chartOptions])
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
%  chartOptions    - Optional struct. Supported field:
%                    weightGridSize [nRows nCols], enabling two-axis
%                    fluorophore layout with scalar (fixed) odBloodLevels.
%
% Returns
%  scene       - Fluorescence chart as an ISETCam scene
%  signalCube  - Fluorescence signals sized [rows x cols x nWave]
%  rcSize      - [rows cols]
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

chartOptions = struct();
if ~isempty(varargin)
    if isstruct(varargin{1})
        chartOptions = varargin{1};
    else
        error('Optional 6th input must be a chartOptions struct.');
    end
end

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

isTwoAxisWeightMode = false;
weightGridSize = [];
if isfield(chartOptions,'weightGridSize') && ~isempty(chartOptions.weightGridSize)
    weightGridSize = chartOptions.weightGridSize(:)';
    if numel(weightGridSize) ~= 2
        error('chartOptions.weightGridSize must be [nRows nCols].');
    end
    if any(weightGridSize < 1) || any(mod(weightGridSize,1) ~= 0)
        error('chartOptions.weightGridSize values must be positive integers.');
    end
    if prod(weightGridSize) ~= nWeight
        error('prod(chartOptions.weightGridSize) must equal size(weights,1).');
    end
    if nBlood ~= 1
        error('Two-axis weight mode requires scalar odBloodLevels (fixed blood density).');
    end
    isTwoAxisWeightMode = true;
end

if isTwoAxisWeightMode
    rcSize = weightGridSize;
else
    rcSize = [nBlood, nWeight];
end

if size(weights,2) ~= 5
    error('weights must have 5 columns (four basis fluorophores + keratin).');
end

signalCube = zeros(rcSize(1),rcSize(2),nWave);
rIdxMap = reshape(1:prod(rcSize),rcSize);

if isTwoAxisWeightMode
    % Build row-major index grid consistent with fluorescenceWeights case-2 flattening.
    idxGrid = reshape(1:nWeight,rcSize(2),rcSize(1))';
    fixedBlood = odBloodLevels(1);
    for rr = 1:rcSize(1)
        for cc = 1:rcSize(2)
            weightIdx = idxGrid(rr,cc);
            thisWeights = weights(weightIdx,:)';
            thisSignal = fluorescenceSignal(wave,fixedBlood,thisWeights);
            signalCube(rr,cc,:) = reshape(thisSignal,1,1,nWave);
        end
    end
else
    for rr = 1:nBlood
        for cc = 1:nWeight
            thisWeights = weights(cc,:)';
            thisSignal = fluorescenceSignal(wave,odBloodLevels(rr),thisWeights);
            signalCube(rr,cc,:) = reshape(thisSignal,1,1,nWave);
        end
    end
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
chartP.twoAxisWeightMode = isTwoAxisWeightMode;
if isTwoAxisWeightMode
    chartP.weightGridSize = weightGridSize;
    chartP.weightIndexGrid = idxGrid;
else
    chartP.weightGridSize = [];
    chartP.weightIndexGrid = [];
end
chartP.keratinParams = [];
chartP.signalSource = 'fluorescenceSignal';

scene = sceneSet(scene,'chart parameters',chartP);

end
