function [cfaN,cfaMap] = sensorImageColorArray(cfa)
%Create an image of the color filter array
%
%    [cfaN,cfaMap] = sensorImageColorArray(cfa)
%
% The input is a color filter array filled with characters describing the
% filter position.  This routine returns color filter  numerical values
% (cfaN and a color map (cfaMap) describing the meaning of these number.
%
% See also:  sensorCheckArray, sensorDetermineCFA, sensorColorOrder
%
% Example:
%   s = sensorCreate;
%   CFAletters = sensorDetermineCFA(s);
%   [CFAnumbers,mp] = sensorImageColorArray(CFAletters);
%   vcNewGraphWin; image(CFAnumbers); colormap(mp)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('cfa'), error('cfa (letter array) required.'); end

% These will be the numbers that indicate which filter is present at each
% position in the color filter array.
cfaN = zeros(size(cfa));

% sensorColorOrder returns a cell array of the letter names used to
% specify color filters (r,g,b,c,y,...).
[cfaOrdering, cfaMap] = sensorColorOrder;

% Assign the corresponding integer to each of the color order values.
for ii = 1:length(cfaOrdering)
    % There first letter of the filter name should be lower
    % We force that here anyway.  There are only some permissible first
    % letter names.
    l = find(lower(cfa) == cfaOrdering{ii});
    if ~isempty(l), cfaN(l) = ii; end
end

% At this point, we should have no 0s in the cfaN.  If we do, then the
% color filter array has a letter in it that is not part of
% sensorColorOrder.

% If no return was requested, assume the user wanted a picture of the
% colors
if nargout == 0
    figure;
    image(cfaN); colormap(cfaMap);
    axis image; zoom on
end

return;
