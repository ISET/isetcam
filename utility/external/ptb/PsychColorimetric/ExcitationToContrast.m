function contrast = ExcitationToContrast(excitation,reference)
% contrast = ExcitationToContrast(excitation,reference)
%
% Convert excitation coordinates to contrast coordinates.
%
% 4/5/02   dhb, ly   Wrote it.

[m,n] = size(excitation);
contrast = (excitation-reference(:,ones(1,n))) ./ reference(:,ones(1,n));

