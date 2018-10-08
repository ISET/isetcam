function contrast = IncrementToContrast(increment,reference)
% contrast = IncrementToContrast(increment,reference)
%
% Convert incremental coordinates to contrast coordinates.
%
% 8/15/96  dhb, abp  Wrote it.
% 4/5/02   dhb, ly   Renamed some variables.

[m,n] = size(increment);
contrast = increment ./ reference(:,ones(1,n));

