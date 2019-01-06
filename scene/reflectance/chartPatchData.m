function mRGB = chartPatchData(obj,mLocs,delta,fullData,dataType)
%Return a cell array with the linear RGB values from an ip or sensor 
%
% Syntax:
%    mRGB = chartPatchData(obj,mLocs,delta)
%
% Description:
%  Returns the linear RGB values from the sensor or processor window
%
% Inputs
%   obj   - An ISET data structure (scene, oi, sensor, ip)
%   mLocs - Middle locations of the patches
%   delta - Width of the square around the center where data are extracted
%
% Optional parameters
%   fullData - Return all the data in a patch (true), or the mean
%              value  in the patch (false, default). 
%   dataType - Data type to return.  Defaults are
%                scene  - 'photons'
%                oi     - 'photons'
%                sensor - 'electrons'
%                ip     - 'result'
%              You can specify certain other data types, as can be returned
%              by vcGetROIData. The interface and options could be written
%              more generally and better (BW).  Look at the header to
%              vcGetROIData to see the options.
% Outputs
%   mRGB - a cell array of the values from each location in the
%          patches (if fullData == true); or, a matrix of the mean values from
%          each patch (if fullData == false, the default) 
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See Also:  
%   chartROI, chartCornerpoints

% Example:
%{
wave = 400:10:700;  radiance = rand(length(wave),50)*10^16;
scene = sceneRadianceChart(wave, radiance,'patch size',25,'rowcol',[5,10]);
sceneWindow(scene);

% Define the corner points
wholeChart = true;
cp = chartCornerpoints(scene,wholeChart);

% Create the rects
chartP = sceneGet(scene,'chart parameters');
sFactor = 0.5;
[rects, mLocs, pSize] = chartRectangles(cp,chartP.rowcol(1),chartP.rowcol(2), sFactor);

% Plot the rects
rectHandles = chartRectsDraw(scene,rects);

delete(rectHandles);

% When fullData is true, each cell has the spectra from a patch
fullData = true;
mRGB = chartPatchData(scene,mLocs,pSize(1)*0.8,fullData);
theseData = mRGB{1};
% For the synthetic scene all the points are the same.
vcNewGraphWin; plot(wave,theseData');  

% When fullData is false, the rows are the mean spectra from each of the
% different patches.
fullData = false;
mRGB = chartPatchData(scene,mLocs,pSize(1)*0.8,fullData);
vcNewGraphWin; plot(wave,mRGB')


%}

%% Parameter validation

if ieNotDefined('obj'),   error('vcimage or sensor required'); end
if ieNotDefined('mLocs'), error('Mid locations required'); end
if ieNotDefined('delta'), error('Patch spacing required'); end
if ieNotDefined('fullData'), fullData = false;  end  % Mean, not all the points
if ieNotDefined('dataType'), dataType = '';     end  % Default for vcimage

%% Data extraction
nLocs = size(mLocs,2);
mRGB = cell(1,nLocs);
switch obj.type
    case 'scene'
        if isempty(dataType), dataType = 'photons'; end
    case 'oi'
        if isempty(dataType), dataType = 'photons'; end
    case 'sensor'
        if isempty(dataType), dataType = 'electrons'; end
    case 'ip'
        if isempty(dataType), dataType = 'result'; end
    otherwise
        error('Unknown object type %s\n',obj.type);
end

for ii = 1:nLocs
    % mLocs(:,mPatch) is a column vector with (row,col)' for the
    % mPatch.
    theseLocs = chartROI(mLocs(:,ii),delta);
    mRGB{ii} = vcGetROIData(obj,theseLocs,dataType);
end
    
if ~fullData  % User just wants the mean value
    meanRGB = zeros(nLocs,size(mRGB{1},2));
    for ii = 1:nLocs
        meanRGB(ii,:) = mean(mRGB{ii});
    end
    mRGB = meanRGB;
end

end
