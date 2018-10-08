function excitation = ContrastToExcitation(contrast,reference)
% excitation = ContrastToExcitation(contrast,reference)
%
% Convert contrast to excitation coordinates.
%
% 4/5/02  dhb, ly  Wrote it.

[m,n] = size(contrast);
excitation = (contrast .* reference(:,ones(1,n))) + reference(:,ones(1,n));
