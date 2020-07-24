function [mRGB,stdRGB] = macbethPatchData(obj,mLocs,delta,fullData,dataType)
% Return a cell array with the linear RGB values from an ip or sensor 
%
%    [mRGB, stdRGB] = macbethPatchData(obj,mLocs,delta)
%
% Input:
%   obj:    A scene, oi, sensor or ip struct
%   mLocs:  Mean locations of the MCC patches
%   delta:  Size of the rect for each patch
%   fullData:  Return all the RGB data from each patch (1) or the mean (0)
%   dataType:  Depends on the object type
%
% Output
%  mRGB:   Either a cell array with data from each of the 24 patches or a
%          matrix (24 x 3) with the mean RGB values from each patch
% stdRGB:  When mean is returned this matrix contains the corresponding
%          standard deviatons 
%
% See Also:  
%   macbethSelect, vcimageMCCXYZ, vcGetROIData, macbethColorError
%

% Examples:
%{
% Add example
%}



%% Parse inputs

if ieNotDefined('obj'),   error('vcimage or sensor required'); end
if ieNotDefined('mLocs'), error('Mid locations required'); end
if ieNotDefined('delta'), error('Patch spacing required'); end
if ieNotDefined('fullData'),fullData = 0; end         % Mean, not all the points
if ieNotDefined('delta'),   dataType = 'result'; end  % Default for vcimage

%%  Get the object using the mLocs and dataType spec

% mLocs() is a 2 x 24 matrix with the center of each patch as
% the (row,col)'
if fullData  % The values from every location in each of the 24 patches
    mRGB = cell(1,24);
    for ii = 1:24 
        theseLocs = macbethROIs(mLocs(:,ii),delta); % List locs for this patch
        mRGB{ii} = vcGetROIData(obj,theseLocs,dataType);
    end
else  % Mean values from each patch

    mRGB   = zeros(24,3);  % This should be 24 x nSensors, not 24 x 3
    stdRGB = zeros(24,3);  % This should be 24 x nSensors
    
    for ii = 1:24
        theseLocs = macbethROIs(mLocs(:,ii),delta);  % List locs for this patch
        % The sensor case will have NaNs
        theseData    = vcGetROIData(obj,theseLocs,dataType);
        mRGB(ii,:)   = nanmean(theseData);
        stdRGB(ii,:) = nanstd(theseData);
    end
end

end
