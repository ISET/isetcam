function [peakRow,peakCol] = psfFindPeak(input)
% [peakRow,peakCol] = psfFindPeak(input)
%
% Find row/col corresponding to max of two dimensional PSF input.
%
% This method works reasonably when there is more than one
% maximum in the input, in that it returns the coordinates of
% one of the maxima.  No thought is investing in figuring out
% which one if there are multiple locations with the identical
% maximal value -- it's just whatever the max() routine picks.
%
% The old method of finding row and column  maxima can screw up in this case,
% by returing the coordinates of a point that isn't a maximum.
%
% 12/22/09  dhb  Encapsulate this as a function with improved method.

BUGGY = 0;

if (BUGGY)
    [nil,peakRow] = max(max(input,[],2));
    [nil,peakCol] = max(max(input,[],1));
else
    [m,n] = size(input);
    [nil,ind] = max(input(:));
    [peakRow,peakCol] = ind2sub([m,n],ind);
    if (input(peakRow,peakCol) ~= max(input(:)))
        error('Value at max location is not input maximum. Hmmm.');
    end
end

end

