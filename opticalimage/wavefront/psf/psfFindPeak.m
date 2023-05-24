function [peakRow, peakCol] = psfFindPeak(input)
% Find row/col corresponding to max of two dimensional PSF input.
%
% Syntax:
%   [peakRow, peakCol] = psfFindPeak(input)
%
% Description:
%    Find row/col corresponding to max of two dimensional PSF input.
%
%    This method works reasonably when there is more than one maximum in
%    the input, in that it returns the coordinates of one of the maxima.
%    No thought is investing in figuring out which one if there are
%    multiple locations with the identical maximal value -- it's just
%    whatever the max() routine picks.
%
% Inputs:
%    input   - Two-dimensional PSF input
%
% Outputs:
%    peakRow - Corresponding row to PSF Max
%    peakCol - Corresponding column to PSF Max
%
% Optional key/value pairs:
%    None.
%

% History:
%    12/22/09  dhb  Encapsulate this as a function with improved method.
%    11/10/17  jnm  Comments & formatting
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    [pR pC] = psfFindPeak([0 1 10 1; 1 2 5 1; 1 1 1 4])
%}

[m, n] = size(input);
[~, ind] = max(input(:));
[peakRow, peakCol] = ind2sub([m, n], ind);
if (input(peakRow, peakCol) ~= max(input(:)))
    error('Value at max location is not input maximum. Hmmm.');
end

end
