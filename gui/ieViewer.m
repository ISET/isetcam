function ieViewer(rgb)
%Calls imview or imtool depending on version number
%
%   ieViewer(rgb)
%
% We handle the case of more than 3 sensors prior to getting here.
% This routine only exists for some backward compatibility with Matlab.

matlabV = version;

if str2num(matlabV(1)) > 6, 
    % The viewer appears to want monochrome images scaled between 0 and 1.
    % So I rescale.
    if ndims(rgb) == 2, rgb = rgb/max(rgb(:)); end
    imtool(rgb);
else
    imview(rgb);
end

return;
