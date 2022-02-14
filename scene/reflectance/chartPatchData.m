function mRGB = chartPatchData(obj,mLocs,delta,fullData,dataType)
%Return a cell array with the linear RGB values from a vcimage or sensor 
%
%    mRGB = chartPatchData(obj,mLocs,delta)
%
% Returns the linear RGB values from the sensor or processor window
%
% Example:
%
% See Also:  
%
% Copyright ImagEval Consultants, LLC, 2011.

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
