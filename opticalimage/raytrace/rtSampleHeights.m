function [imgHeight,maxDataHeight] = rtSampleHeights(allHeights,dataHeight)
% Find image height values from ray trace that are within the oi field height
%
%   [imgHeight,maxDataHeight] = rtSampleHeights(allHeights,dataHeight)
%
% The list of ray trace image heights needed for the data are returned in
% imgHeight. The highest value of the data is in maxDataHeight. The units
% returned are the same as those sent in.  Typically, these are in
% millimeters.
%
% See also: rtPrecomputePSFApply, rtPSFApply
%
% Examples:
%  Suppose we only want to compute half the image:
%
%    allHeights = opticsGet(optics,'rtPSFfieldHeight','mm');
%    dataHeight = oiGet(oi,'height','mm')
%    [imgHeight,maxDataHeight] = rtSampleHeights(allHeights,dataHeight/2)
%
% Copyright ImagEval, LLC, 2005

% This is how far the data extend
maxDataHeight = max(dataHeight(:));

% This is the list of ones we will keep
list = false(length(allHeights),1);

% Add the next one to the list.  If it is less than the max, keep
% going.  Otherwise, you are done.
for ii=1:length(allHeights)
    list(ii) = 1;
    if (allHeights(ii) <= maxDataHeight)  % continue
    else
        break;
    end
end

% Shorten the list
imgHeight = allHeights(list);

return;