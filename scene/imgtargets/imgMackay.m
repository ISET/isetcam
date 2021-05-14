function img  = imgMackay(radialFrequency,imSize)
% Create a MacKay chart spatial pattern.
%
%   img  = imgMackay(radialFrequency,imSize)
%
% The Mackay chart has lines at many angles and increases in spatial
% frequency from periphery to center.  This routine is called in creating
% the Mackay scene (sceneWindw).
%
% Examples
%  img =  imgMackay;  imagesc(img); colormap(gray); axis image
%  img  = imgMackay(12,256);  imagesc(img); colormap(gray); axis image
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('radialFrequency'), radialFrequency = 8; end
if ieNotDefined('imSize'),          imSize = 128; end

mx = round(imSize/2); mn = -(mx-1);
[x, y] = meshgrid(mn:mx, mn:mx);
l = (x == 0);
x(l) = eps;

img = cos(atan(y./x)*2*radialFrequency);
img =  ieScale(img,1,256);

return;
