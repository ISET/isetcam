function img = truncate(img, minBound, maxBound)
% truncate(img, minBound, maxBound)
%	Returns the imgrix truncated to the minimum and maximum values
%	specified.  MinBound and maxBound default to 0 and 1 respectively
%	if not specified.
%
% Rick Anthony
% 11/19/93

if (nargin < 2)
    minBound = 0;
    maxBound = 1;
end


index = find(img < minBound);
img(index) = minBound * ones(size(index));

index = find(img > maxBound);
img(index) = maxBound * ones(size(index));
