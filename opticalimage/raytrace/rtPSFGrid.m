function [xGrid,yGrid,hRes] = rtPSFGrid(oi,units)
% Create an x-y sampling grid for PSF at the optical image spacing
%
%  [xGrid,yGrid,hRes] = rtPSFGrid(oi,units)
%
% The PSF is sampled at a high resolution (128x128) 0.25 micron spacing.
% Ordinarly, the optical image is sampled at a much lower resolution.  We
% return the number of grid samples at the optical image resolution to use
% when adding a ray-trace PSF into the output image 
%
% Called by rtPSFApply
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('units'), units = 'm'; end

% Resolution of the optical image samples
hRes = oiGet(oi,'sampleSpacing',units);  % x,y; width,height; col,row

optics = oiGet(oi,'optics');

% Sample positions of the ray trace data
psfSupportY = opticsGet(optics,'rtpsfSupportRow',units);
psfSupportX = opticsGet(optics,'rtpsfSupportCol',units);

% We had some trouble with rounding error at the minimum.  The xGrid1 and
% yGrid1 must never exceed the psfSupport at either end. This method of
% calculating should keep everything in bounds and include 0.
xGrid1 = 0:hRes(1):psfSupportX(end);
tmp    = -1*fliplr((0:hRes(1):abs(psfSupportX(1))));
xGrid1 = [tmp(1:(end-1)), xGrid1];

yGrid1 = (0:hRes(2):psfSupportY(end)); 
tmp    = -1*fliplr((0:hRes(2):abs(psfSupportY(1))));
yGrid1 = [tmp(1:(end-1)), yGrid1];

[xGrid,yGrid] = meshgrid(xGrid1,yGrid1);

return;
