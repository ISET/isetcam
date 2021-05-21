function xyz = srgb2xyz(srgb)
% Transform srgb to CIE XYZ
%
%    xyz = srgb2xyz(srgb)
%
% Brief description:
%   Convert sRGB image into CIE XYZ values. The input range for srgb
%   values is (0,1).
%
% Inputs
%   sRGB:  RGB format image
%
% Outputs
%   xyz :  RGB format image
%
% Description:
%
% The sRGB display is defined by three primaries with these chromaticity
% coordinates (x,y,Y) and luminance
%
%     R       G     B         White point
% x	0.6400	0.3000	0.1500     0.3127
% y	0.3300	0.6000	0.0600     0.3290
% Y	0.2126	0.7152	0.0722     1.0000
%
% For a full description of the sRGB format, see this reference:
%    http://en.wikipedia.org/wiki/SRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

% Data format should be in RGB format
if ndims(srgb) ~= 3
    error('srgb2xyz:  srgb must be a NxMx3 color image.  Use XW2RGBFormat if needed.');
end

% Convert the srgb values to the linear form in the range (0,1)
lrgb = srgb2lrgb(srgb);  %imtool(lrgb/max(lrgb(:)))

% convert lrgb to xyz
matrix = colorTransformMatrix('lrgb2xyz');
xyz = imageLinearTransform(lrgb, matrix);

end
