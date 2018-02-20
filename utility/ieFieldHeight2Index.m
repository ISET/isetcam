function [idx1,idx2] = ieFieldHeight2Index(fieldHeightList,height)
% Find the field height index closest to a specific height (meters)
%
%    [idx1,idx2]  = ieFieldHeight2Index(fieldHeightList,height)
%   
% You can also request a pair of indices that bound the value.  In that
% case, idx1 < idx2 and 
%
%     fieldHeightList(idx1) <= height <= fieldHeightList(idx2)
%
% Typically the field heights are in meters and the request is in meters.
% This routine will run correctly as long as fieldHeightList and height are
% both in common units.  If they are in different units, bad things happen.
%
% Example (in meters)
%   fieldHeightList = opticsGet(optics,'rtPSFfieldHeight');  % meters
%   fhIdx = ieFieldHeight2Index(fieldHeightList,2e-4)
%   [idx1,idx2]  = ieFieldHeight2Index(fieldHeightList,2e-4)
%
%  Or run in millimeters - 
%   fieldHeightList = opticsGet(optics,'rtPSFfieldHeight','mm'); 
%   fhIdx = ieFieldHeight2Index(fieldHeightList,0.2)
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming Note:  We could return weights that might be used for
% interpolation 

% This is the index with a value closest to height
[v,idx1] = min(abs(fieldHeightList - height));

% Determine two indices that bound the height value.
if nargout == 2
    if fieldHeightList(idx1) > height
        % Send back the index below.  Order everything properly
        idx2 = max(1,idx1 - 1);
        tmp = idx1; idx1 = idx2; idx2 = tmp;
    else
        % Send back the index above.  No need to order
        idx2 = min(length(fieldHeightList),idx1 + 1);
    end
end

return;
