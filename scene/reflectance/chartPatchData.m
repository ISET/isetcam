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
%   obj   - An ISET sensor or processor (ip) data structure
%   mLocs - Middle locations of the patches
%   delta - Center-to-center spacing of the patches
%
% Optional parameters
%   fullData - Logical. Return all the data in a patch (default is
%              false, which is mean value only).
%   dataType - Default is 'result' for ip object and 'volts' for
%              sensor.  You can specify a different data type. Options
%              are in vcGetROIData. 
% Outputs
%   mRGB - a cell array of linear RGB values from the patches
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See Also:  
%

% Example:
%

if ieNotDefined('obj'),   error('vcimage or sensor required'); end
if ieNotDefined('mLocs'), error('Mid locations required'); end
if ieNotDefined('delta'), error('Patch spacing required'); end
if ieNotDefined('fullData'),fullData = 0; end         % Mean, not all the points
if ieNotDefined('dataType'),   dataType = 'result'; end  % Default for vcimage

nLocs = size(mLocs,2);
if fullData  % Every value in the patch
    mRGB = cell(1,nLocs);
    for ii = 1:nLocs
        % mLocs(:,mPatch) is a column vector with (row,col)' for the
        % mPatch.
        theseLocs = chartROI(mLocs(:,ii),delta);
        mRGB{ii} = vcGetROIData(obj,theseLocs,dataType);
    end
else  % Mean values from each patch
    % I don't think this path has been used or tested much (BW).
    mRGB = zeros(nLocs,3);
    for ii = 1:nLocs
        % mLocs(:,mPatch) is a column vector with (row,col)' for the
        % mPatch.
        % This code doesn't work properly for the case of an image sensor.
        % It needs to protect against the NaNs returned in that case.  It
        % works OK for the vcimage.  Fix this some day.
        if strcmp(obj.type,'sensor'), error('Use fullData = 1'); end
        theseLocs = chartROI(mLocs(:,ii),delta);
        mRGB(ii,:) = mean(vcGetROIData(obj,theseLocs,dataType));
    end
end

return
