function alpha = displayMaxContrast(signalDir, backDir)
% Find the scalar the produces the maximum contrast for a signal given a
% background.
%
%   alpha = displayMaxContrast(signalDir,backDir)
%
% With the scalar alpha applied to the signal, the total signal reaches
% one or the other display boundary in the equation.  This routine is
% useful, for example, in finding the maximum contrast cone-isolating
% stimulus that can be displayed on a particular monitor.
%
%        0 <= alpha*signalDir + backDir
%            alpha*signalDir + backDir <= 1
%
% Copyright ImagEval Consultants, LLC, 2005.

for ii = 1:3
    if signalDir(ii) > 0
        mx(ii) = (1 - backDir(ii)) / signalDir(ii);
    else
        mx(ii) = abs(-backDir(ii)/signalDir(ii));
    end
end
alpha = min(mx);

return;
