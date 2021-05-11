function tickLocs = ieChooseTickMarks(val, nTicks)
%Choose sensible values for tick marks (or at least try)
%
%   tickLocs = ieChooseTickMarks(val,[nTicks = 10])
%
%   Choose tick mark locations on an axis with the values in val.
%   val:        Values on this axis.
%   nTicks:     Number of ticks.  Default = 10.
%
% Example:
%  tickLocs = ieChooseTickMarks(0:500,5)
%
% Copyright ImagEval Consultants, LLC, 2003.


% Programming notes
% This routine fails when nTicks > (mx-mn)
%

if ieNotDefined('nTicks'), nTicks = 10; end

% Choose a reasonable number of positive tick marks
mx = round(max(val));
mn = round(min(val));
tickSpacing = round((mx-mn)/nTicks);

E = floor(log10(mx - mn));
S = 10^(E - 1);
tickSpacing = S * round(tickSpacing/S);

if mn < 0 & mx > 0
    tickLocs = [0:tickSpacing:mx];
    tickLocs = [fliplr(-1 * [tickSpacing:tickSpacing:abs(mn)]), tickLocs];
else
    tickLocs = [mn:tickSpacing:mx];
end

return;