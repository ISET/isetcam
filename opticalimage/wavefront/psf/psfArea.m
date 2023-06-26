function [val,psfN] = psfArea(psf,X,Y)
% Compute the area under a PSF given the spatial samples
%
% Synopsis
%  [val,psf] = psfArea(psf,X,Y)
%
% Brief synopsis
%  Calculate the volume under under a sampled PSF surface.  We assume
%  that spatial samples are equally spaced on a grid so each PSF
%  sample represents the same surface area.
%
% Input
%   psf - Sampled pointspread function
%   X,Y - Spatial sampling positions. 
%
%    * vectors of x and y samples or 
%    * matrices of X,Y samples.
%
%  If vectors, then [X,Y] = meshgrid(x,y)
%  If matrices, then x = X(1,:), y = Y(:,1)
%
% Output
%  val  - Area under the psf surface
%  psfN - psf scaled to unit volume with respect to the spatial
%         sampling unit (meters, or millimeters, or microns)
%
% Notes:
%  The spatial sampling units can be microns, millimeters, meters, The
%  volume under the PSF surface is with respect to those units, which
%  are not specified here.
%
%  The spatial integration function implemented here may not be
%  precise with respect to the grid. We are sampling the corners of
%  the spatial grid patches rather than the centers of the patches.
%  This function could be numemrically improved.  If you know a better
%  thing to do, Please do!
%
% See also
%  psf2lsf
%

% Find the area of each patch
if  isvector(X) && isvector(Y)
    dx = X(2) - X(1);
    dy = X(2) - Y(2);
elseif ismatrix(X) && ismatrix(Y)
    dx = X(1,2) - X(1,1);
    dy = Y(2,1) - Y(1,1);
else
    error('Unexpected X,Y format. Both should be vectors or matrices.')
end

% Scale the psf samples by the patch area. The algorithm assumes that
% the patches all have the same area!  The returned volume has units
% of PSF units times squared spatial units.
val = sum(psf(:))*dx*dy;

if nargout == 2, psfN = psf/val; end

end
