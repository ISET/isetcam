function [cHistN, cHistX] = plotContrastHistogram(data)
%
%   [cHistN,cHistX] = plotContrastHistogram(data)
%
% Author: Wandell
% Date:   March 18, 2003
% Purpose:
%    Plot or return a contrast histogram of the input data.  These data may
%    be in an image matrix format.  Here they are converted to a list of
%    numbers and the contrast is computed.
%    If there are no output arguments, a figure is created and the histogram is plotted.
%    If there are two outputs, the histogram values are returned.  These
%    can be plotted using
%
%               plot(cHistX,cHistN,'o')
%               bar(cHistX, cHistN)
%
%    or other general routines


% Calculate the contrast values for this data set.
m = mean(data(:));
cdata = (data(:) - m) / m;

% If there are no output values, just create a figure and put it up.
if nargout < 2
    figure; histogram(cdata)
else
    % Otherwise, return the histogram data for plotting
    [cHistN, cHistX] = histogram(cdata);
end

return;
