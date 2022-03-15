function [scene, sSamples, reflectance, rcSize] = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling)
% Create a reflectance chart for testing
%
%   [scene, sampleList, reflectances, rcSize] = ...
%      sceneReflectanceChart(sFiles,sSamples,pSize,[wave],[grayFlag=1],[sampling])
%
% A reflectance chart is created.  The parameters needed to recreate the
% chart are attached to the scene structure.  To retrieve these from the
% scene use: sceneGet(scene,'chart parameters');
%
% Inputs
%  The surfaces are drawn from the cell array of sFiles{}.
%  sFiles:   Cell array of file names with reflectance spectra
%            It is also possible to set sFiles to a matrix of reflectances.
%  sSamples: This can either be
%      - Vector indicating how many surfaces to sample from each file
%      - A cell array specifying the list of samples from each file
%  pSize:    The number of pixels on the side of each square patch
%  wave:     Wavelength Samples
%  grayFlag: Fill the last part of the chart with gray surfaces, the last
%            one being a white patch and the others sampling different gray
%            level reflectances
%  sampling: With "r', or without replacement (anything else) from the
%            surface reflectances (replacement by default)
%
% Returns
%   scene:         Reflectance chart as a scene
%   sSamples:      A cell array of the surfaces from each file, as above
%   reflectances:  The actual reflectances
%   rcSize:        Row and column sizes
%
% If a specific set of samples is chosen they are written out in row
% first ordering, [ 1 4 7; 2 5 8; 3 6 9]
%
% Copyright ImagEval Consultants, LLC, 2010.
%
% See also:
%   macbethChartCreate, sceneRadianceChart

% Examples:
%{
 s = sceneCreate('reflectance chart');
 p = sceneGet(s,'chart parameters');
 sceneWindow(s);
%}
%{
 s2 = sceneReflectanceChart(p.sFiles,p.sSamples,p.pSize,p.wave,p.grayFlag,p.sampling);
 sceneWindow(s2);
%}
%{
 s  = sceneCreate('reflectance chart');
 p  = sceneGet(s,'chart parameters');
 s2 = sceneCreate('reflectance chart',p);
 sceneWindow(s); sceneWindow(s2);
%}

%%
if ieNotDefined('sFiles'), error('Surface files required');
else,                      nFiles = length(sFiles);
end

if ieNotDefined('pSize'),    pSize = 32; end
if ieNotDefined('grayFlag'), grayFlag = 1; end
if ieNotDefined('sampling'), sampling = 'r'; end %With replacement by default

%% Default scene
scene = sceneCreate('empty');
if ieNotDefined('wave'), wave = sceneGet(scene,'wave');
else                   
    scene = sceneSet(scene,'wave',wave);
    scene = sceneSet(scene,'illuminant wave',wave);
end
nWave = length(wave);
defaultLuminance = 100;  % cd/m2

% Get the reflectance samples
if iscellstr(sFiles)
    if ieNotDefined('sSamples'), error('Surface samples required'); end
    if length(sSamples) ~= nFiles
        error('Mis-match between number of files and sample numbers');
    end
    [reflectance, sSamples] = ieReflectanceSamples(sFiles,sSamples,wave,sampling);
    
    % sSamples might be a vector, indicating the number of samples, or a cell
    % array specifying which samples.
    if iscell(sSamples)
        nSamples = 0;
        for ii=1:nFiles, nSamples = length(sSamples{ii}) + nSamples; end
    else, nSamples = sum(sSamples);
    end
else
    reflectance = sFiles;
    nSamples = size(reflectance,2);
end

% Spatial arrangement
r = ceil(sqrt(nSamples)); c = ceil(nSamples/r);

% reflectance is in wave x surface format.  We fill up the end of the matrix with
% gray surface reflectances.
if grayFlag
    % Create a column of gray surfaces, from 100% reflectance scaling down
    % in steps of 0.5 (0.3 log unit)
    s = logspace(0,log10(0.05),r);
    g = ones(nWave,r)*diag(s);
    reflectance = [reflectance, g];
    c = c + 1;
end
rcSize = [r,c];

% Convert the scene reflectances into photons assuming an equal energy
% illuminant.
ee         = ones(nWave,1);           % Equal energy vector
e2pFactors = Energy2Quanta(wave,ee);  % Energy to photon factor

% Illuminant
illuminantPhotons = diag(e2pFactors)*ones(nWave,1);

% Convert the reflectances into photons
% Data from first file are in the left columns, second file next set of
% cols, and so forth. There may be a gray strip at the end.
% Scale reflectances by incorporating energy to photon scale factr
radiance = diag(e2pFactors)*reflectance;

% Calculate the scene radiance data.  These are in photon units, but
% they are not scaled to reasonable photon values.
sData = zeros(rcSize(1),rcSize(2),nWave);
% ZLY: Addded index map chart to retrive basis function wgts.
rIdxMap = zeros(size(sData, 1, 2));
for rr=1:rcSize(1)
    for cc=1:rcSize(2)
        idx = sub2ind(rcSize,rr,cc);
        if idx <= size(radiance,2)
            sData(rr,cc,:) = radiance(:,idx);
            rIdxMap(rr, cc) = idx;
        else
            sData(rr,cc,:) = 0.2*illuminantPhotons;
        end
    end
end

% Store the photon data as XYZ, too. We will need these for evaluation of
% color algorithms later (sensor and illuminant correction).  These are
% stored in RGB format here (row,col,wave).
XYZ = ieXYZFromPhotons(sData,wave);

% Build up the size of the image regions - still reflectances
sData = imageIncreaseImageRGBSize(sData,pSize);
% ZLY: Resize index map 
rIdxMap = imageIncreaseImageRGBSize(rIdxMap, pSize);

% Add data to scene, using equal energy illuminant
scene = sceneSet(scene,'photons',sData);
scene = sceneSet(scene,'illuminantPhotons',illuminantPhotons);
scene = sceneSet(scene,'illuminantComment','Equal energy');
scene = sceneSet(scene,'name','Reflectance Chart (EE)');
% ieAddObject(scene); sceneWindow;

% Adjust the illuminance to a default level in cd/m2
scene = sceneAdjustLuminance(scene,defaultLuminance);
% ieAddObject(scene); sceneWindow;

% Attach the chart parameters to the scene object so we can easily find the
% centers later
chartP.sFiles   = sFiles;
chartP.sSamples = sSamples;
chartP.grayFlag = grayFlag;
chartP.sampling = sampling;
chartP.pSize    = pSize;
chartP.wave     = wave;

chartP.XYZ      = XYZ;
chartP.rowcol   = rcSize;
chartP.rIdxMap = rIdxMap;

scene = sceneSet(scene,'chart parameters',chartP);

end



