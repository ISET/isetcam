function [scene, rcSize] = sceneRadianceChart(wave,radiance,varargin)
% Create a radiance chart for testing
%
%   [scene, sampleList, reflectances, rcSize] = ...
%      sceneRadianceChart(wave,radiance,...)
%
% Descriptiopn:
%   A radiance chart is created.  Each patch in the chart has a
%   radiance drawn from the radiance input. The parameters needed to
%   recreate the chart are attached to the scene structure.
%
% Required inputs
%  wave      - Wavelength samples
%  radiance  - Radiance data in quantal units (q/s/sr/nm/m2).  These
%              are samples in the columns of the matrix (nWave x nSamples)
%
% Optional key/value pairs
%  rowcol:      Force a particular size of row/col
%  patch size:  The number of pixels on the side of each square patch
%  gray fill:   Add to the chart a column of gray radiance,
%               the last one being a white patch and the others
%               sampling different gray level reflectances (Default is
%               true)
%  sampling:    With replacement ('r'), or without replacement
%  (anything else) from the radiances (replacement by default)
%
% Returns
%   scene:         Radiance chart as a scene
%
% The radiance samples are placed as ordered in the columns.
%  
%Example:
%  s = sceneCreate('radiance chart',wave,radiance, ...);
%  sceneGet(s,'chart parameters');
%  ieAddObject(s); sceneWindow;
%
% Copyright ImagEval Consultants, LLC, 2018.
%
% See also: 
%   macbethChartCreate, sceneReflectanceChart
%

%% Parse input parameters for patch size, gray filling and sampling
p = inputParser;
varargin = ieParamFormat(varargin);

p.addRequired('wave',@isvector);
p.addRequired('radiance',@ismatrix);

p.addParameter('patchsize',10,@isscalar);
p.addParameter('sampling','r',@ischar);
p.addParameter('grayfill',true,@islogical);
p.addParameter('rowcol',[],@isvector)

p.parse(wave,radiance,varargin{:});

pSize    = p.Results.patchsize;
grayFill = p.Results.grayfill;
sampling = p.Results.sampling;
rowcol   = p.Results.rowcol;

%% Default scene
scene = sceneCreate('empty');
scene = sceneSet(scene,'wave',wave);
nWave = length(wave);

% Radiance is in wave x surface format.  
nSamples = size(radiance,2);

% Spatial arrangement
if isempty(rowcol)
    r = ceil(sqrt(nSamples)); c = ceil(nSamples/r);
else
    r = rowcol(1); c = rowcol(2);
end

if r*c > nSamples
    % We need more samples.  Sample some of the radiance columns and
    % add them the radiance matrix.  We should read the 'sampling'
    % parameter and do this accordingly.  Right now we only have
    % sampling with replacement on for these additional samples.
    nMissing = r*c - nSamples;
    lst      = randi(nSamples,[nMissing,1]);
    extra    = radiance(:,lst);
    radiance = [radiance,extra];
end

% We might add columns to the radiance matrix with gray radiance.  The
% level of the radiance is around the level of the radiances in the
% radiance matrix.
if grayFill
    meanLuminance = mean(ieLuminanceFromPhotons(radiance',wave));
    % Create one column of gray radiances with a dynamic range of 2:1
    % Set the mean luminance level to match the mean luminance of the
    % teeth.  This calculation gets the luminance
    L = ieLuminanceFromPhotons(ones(nWave,1),wave);
    
    s = logspace(-0.3,1,r);  % A little darker to 10x lighter
    % Set the base at the mean luminance; and then scale lower and higher
    grayColumn = ones(nWave,r)*(meanLuminance/L)*diag(s);
    
    % Add the columns
    radiance = [radiance, grayColumn];
    c = c + 1;
end
rcSize = [r,c];


% Illuminant
illuminantPhotons = grayColumn(:,end); 

% Build up the size of the image regions - still reflectances
% Turn the radiance into the RGB format.
sData = XW2RGBFormat(radiance',r,c);
sData = imageIncreaseImageRGBSize(sData,pSize);

% Add data to scene, using equal energy illuminant
scene = sceneSet(scene,'photons',sData);
scene = sceneSet(scene,'illuminantPhotons',illuminantPhotons);
scene = sceneSet(scene,'illuminantComment','Equal energy');
scene = sceneSet(scene,'name','Radiance Chart (EE)');
% sceneWindow(scene);

% Attach the chart parameters to the scene object so we can easily find the
% centers later
chartP.patchSize = pSize;
chartP.grayFill  = grayFill;
chartP.sampling  = sampling;
chartP.rowcol    = rcSize;
scene = sceneSet(scene,'chart parameters',chartP);

end



