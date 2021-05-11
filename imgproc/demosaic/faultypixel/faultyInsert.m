function img = faultyInsert(list, img, val)
% Insert dead pixels into an RGB image
%
%    img = faultyInsert(list,img,val)
%
% See also:
%  faultyList, FaultyBilinear
%
% Examples:
%
% Copyright ImagEval Consultants, LLC, 2006.

if ieNotDefined('list'), error('List required'); end
if ieNotDefined('img'), error('RGB image NxMx3 required'); end
if ieNotDefined('val'), val = 0; end

for ii = 1:size(list, 1)
    img(list(ii, 2), list(ii, 1), :) = val;
end

return;
