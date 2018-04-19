function mRGB = macbethPatchData(obj,mLocs,delta,fullData,dataType)
% Return a cell array with the linear RGB values from a vcimage or sensor 
%
%    mRGB = macbethPatchData(obj,mLocs,delta)
%
% Returns the linear RGB values from the sensor or processor window
%
% Example:
%   Add example
%
% See Also:  macbethSelect, vcimageMCCXYZ, macbethColorError
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Parse inputs

if ieNotDefined('obj'),   error('vcimage or sensor required'); end
if ieNotDefined('mLocs'), error('Mid locations required'); end
if ieNotDefined('delta'), error('Patch spacing required'); end
if ieNotDefined('fullData'),fullData = 0; end         % Mean, not all the points
if ieNotDefined('delta'),   dataType = 'result'; end  % Default for vcimage

%%
if fullData  % Every value in the patch
    mRGB = cell(1,24);
    for ii = 1:24
        % mLocs(:,mPatch) is a column vector with (row,col)' for the
        % mPatch.
        theseLocs = macbethROIs(mLocs(:,ii),delta);
        mRGB{ii} = vcGetROIData(obj,theseLocs,dataType);
    end
else  % Mean values from each patch
    for ii = 1:24
        % mLocs(:,mPatch) is a column vector with (row,col)' for the
        % mPatch.
        % This code doesn't work properly for the case of an image sensor.
        % It needs to protect against the NaNs returned in that case.  It
        % works OK for the vcimage.  Fix this some day.
        if strcmp(obj.type,'sensor'), error('Use fullData = 1'); end
        theseLocs = macbethROIs(mLocs(:,ii),delta);
        mRGB(ii,:) = mean(vcGetROIData(obj,theseLocs,dataType));
    end
end

return
