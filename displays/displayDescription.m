function str = displayDescription(thisD)
% Text description of the display properties, displayed in display window
%
% This will be replaced by an iePTable call
%
% Synopsis
%   str = displayDescription(display)
%

%  Example:
%   d = displayCreate('LCD-Apple');
%   str = displayDescription(d)
%
% (HJ) May, 2014

if ieNotDefined('thisD'), thisD = []; end

if isempty(thisD)
    str = 'No display structure';
else
    str = sprintf('Name:\t%s\n', displayGet(thisD, 'name'));

    wave = displayGet(thisD, 'wave');
    spacing = displayGet(thisD, 'binwidth');
    str = addText(str, sprintf('Wave:\t%d:%d:%d nm\n', ...
        min(wave(:)), spacing, max(wave(:))));
    str = addText(str, sprintf('# primaries:\t%d\n', ...
        displayGet(thisD, 'nprimaries')));
    str = addText(str, sprintf('Color bit depth:\t%d\n', ...
        displayGet(thisD, 'bits')));
    rgb = displayGet(thisD, 'rgb');
    str = addText(str, sprintf('Image width: %d\t Height: %d', ...
        size(rgb, 2), size(rgb, 1)));

end

end

%% END