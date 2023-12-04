function ieViewer(rgb)
%Calls imageViewer depending on version number
%
% To deprecate
%
%   ieViewer(rgb)
%
% We handle the case of more than 3 sensors prior to getting here.
% This routine only exists for some backward compatibility with Matlab.

matlabV = version;

if str2num(matlabV(1)) > 6 %#ok<ST2NM>
    % The viewer appears to want images scaled between 0 and 1.
    % So I rescale.
    if ismatrix(rgb), rgb = rgb/max(rgb(:)); end
    imageViewer(rgb);
else
    imageViewer(rgb);
end

end
