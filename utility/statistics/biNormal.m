function g = biNormal(xSpread, ySpread, theta, N)
%Compute bivariate normal function
%
%  g = biNormal(xSpread,ySpread,theta,N)
%
% This does not properly account for a full covariance matrix.  It only has
% different std dev on x and y.  But you can rotate the thing.  The
% ordering is (a) build a bivariate normal aligned with (x,y) and scaled
% by the x and y spreads, (b) rotate the result.
%
% Example
%   g = biNormal(5,10,0,128); imagesc(g), axis image;
%   g = biNormal(5,10,45,128); imagesc(g), axis image;
%   g = biNormal(5,10,45,16); imagesc(g), axis image;
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('xSpread'), error('x sd required'); end
if ieNotDefined('xSpread'), error('x sd required'); end
if ieNotDefined('theta'), theta = 0; end
if ieNotDefined('N'), N = 128; end

if xSpread > 0.5 * N || ySpread > 0.5 * N
    warning(sprintf('Large spread compared to support %f %f', xSpread, ySpread))
end

xG = fspecial('gauss', [1, N], xSpread);
yG = fspecial('gauss', [N, 1], ySpread);
g = (yG(:) * xG(:)');

if theta ~= 0, g = imrotate(g, theta, 'crop'); end

return;