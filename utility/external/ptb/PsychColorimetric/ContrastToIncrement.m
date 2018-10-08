function increment = ContrastToIncrement(contrast,reference)
% increment = ContrastToIncrement(contrast,reference)
%
% Convert contrast to incremental coordinates.
%
% 8/15/96  dhb, abp  Wrote it.
% 4/5/02   dhb, ly   Renamed some variables, made it work.

[m,n] = size(contrast);
increment = contrast .* reference(:,ones(1,n));

