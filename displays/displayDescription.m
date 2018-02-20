function str = displayDescription(d)
%% function displayDescription(display)
%   Text description of the display properties, displayed in display window
%   
%  Example:
%   d = displayCreate('LCD-Apple');
%   str = displayDescription(d)
%
% (HJ) May, 2014

if ieNotDefined('d'), d = []; end
global vcSESSION

if isempty(d)
    str = 'No display structure';
else
    str = sprintf('Name:\t%s\n', displayGet(d, 'name'));
    
    wave = displayGet(d,'wave');
    spacing = displayGet(d,'binwidth');
    str = addText(str,sprintf('Wave:\t%d:%d:%d nm\n', ...
                        min(wave(:)),spacing,max(wave(:))));
    
                    
    str = addText(str, sprintf('# primaries:\t%d\n', ...
                            displayGet(d, 'nprimaries')));
    str = addText(str, sprintf('Color bit depth:\t%d\n', ...
                            displayGet(d, 'bits')));
    I = vcSESSION.imgData;
    str = addText(str, sprintf('Image width: %d\t Height: %d', ...
                            size(I, 2), size(I, 1)));
    
end

%% END