function radius = ieRadialMatrix(nx,ny,centerx,centery)
% Returns a matrix with entries equal to the radial distance from the center
%
% Synopsis
%   radius = ieRadialMatrix(nx,ny,centerx,[centery])
%
% Brief
%  Return an n by n matrix whose entries are the
%  radial distance in pixels from the center pixel.
%
%  This matrix is a useful thing to pre-compute for
%  performing certain 2D image processing operations.
%
%  The no-loop algorithm is due to Stan Klein.  
%
%  Taken from Psychtoolbox where it is called MakeRadiusMat
%
% 7/11/94		dhb		Slick version.
%
% See also

% Argument re-write for backward compatibility
if (nargin == 3)
	centery = centerx;
end

% Create an ny by nx matrix.  Each row is identical and
% contains the square of its x coordinate relative to 
% the center.
x = (1:nx) - centerx;
Mx = ones(ny,1)*(x.^2);

% Create an ny by nx matrix.  Each column is identical and
% contains the square of its y coordinate relative to
% the center.
y = (1:ny)' - centery;
My = (y.^2)*ones(1,nx);

% Form the desired matrix as
radius = sqrt(Mx + My);

end
