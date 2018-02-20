function img = imgRadialRamp(sz, expt, origin)
% imgRadialRamp - Make a radial ramp function
% 
%  img = imgRadialRamp(sz, expt, origin)
% 
% The radial ramp can be either linear (default) or raised to power EXPT
% (default = 1).  The origin is normally in the center of the image
% (default = (size+1)/2, [1 1] = upper left), but its location can be
% specified (ORIGIN).  The default size sz = (row,col) is 256,256.
%
% Examples:
%   img = imgRadialRamp([384,384]);  imagesc(img); axis image
%   img = imgRadialRamp([128,128],2,[1,1]); imagesc(img); axis image
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sz'),      sz = [256,256]; end
if ieNotDefined('expt'),    expt = 1;  end
if ieNotDefined('origin'),  origin = (sz+1)/2; end

[xramp,yramp] = meshgrid( [1:sz(2)]-origin(2), [1:sz(1)]-origin(1) );

img = (xramp.^2 + yramp.^2).^(expt/2);

return;