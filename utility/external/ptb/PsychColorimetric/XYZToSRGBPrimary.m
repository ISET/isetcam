function [rgb,M] = XYZToSRGBPrimary(XYZ)
% [rgb,M] = XYZToSRGBPrimary(XYZ)
%
% Convert between CIE XYZ to sRGB primary
% coordinates.  These are linear device
% coordinates for the primaries of the sRGB
% standard.  If your input is scaled in the
% gamut of the monitor, the numbers will come
% out in the range 0-1.  You may want to scale
% the result into the range 0-1 before applying
% sRGB gamma correction. 
%
% Originally implemented from conversion matrix as specified at:
%   http://www.srgb.com/basicsofsrgb.htm
% It turns out this was the draft standard.  The site above is gone
% You can still find the draft standard at:
%   http://www.colour.org/tc8-05/Docs/colorspace/61966-2-1.pdf
%
% I can't find the official technical standard on the web, but
% there is pretty good agreement across web sources.  Wikipedia
% seems fine, as does.
%   http://www.w3.org/Graphics/Color/sRGB
%
% 5/1/04	dhb				Wrote it.
% 7/8/10    dhb             Updated to match standard I can now find on the web.

% Define the transformation matrix.  Now matching what's at w3.org.  The
% old matrix is commented out in the second line.
M = [3.2410 -1.5374 -0.4986 ; -0.9692 1.8760 0.0416 ; 0.0556 -0.2040 1.0570];
%M = [3.2406 -1.5372 -0.4986 ; -0.9689 1.8758 0.0415 ; 0.0557 -0.2040 1.0570];

% Do the transform
if (~isempty(XYZ))
    rgb = M*XYZ;
else
    rgb = [];
end


