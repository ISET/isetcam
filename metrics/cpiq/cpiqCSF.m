function csf = cpiqCSF(v)
% Calculate CSF for CPIQ standard
%
%  csf = cpiqCSF(v)
%
% Units of v are cycles per degree
%
% Example:
%   v = 0.5:.5:30;
%   csf = cpiqCSF(v);
%   vcNewGraphWin; plot(v,csf);
%   xlabel('Freq (cpd)'); ylabel('Relative sensitivty');
%
% Copyright ImagEval Consultants, LLC, 2005.

a = 75;
b = 0.2;
c = 0.8;
K = 34.05;

csf = a * (v.^c) .* exp(-b*v) / K;

% Normalize to 1.  The normalization is irrelevant for the acutance
% calculation.
csf = csf / max(csf(:));

return
