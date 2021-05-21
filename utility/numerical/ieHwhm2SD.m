function s = ieHwhm2SD(h,gDim)
% Convert half width half max to standard deviation for Gaussian
%
%   s = ieHwhm2SD(h,gDim)
%
% Example:
%  We calculate the SD for a Gaussian with hwhm of 10; then we plot to show
%  that it reaches a value of 0.5 at 10 units from the center
%
%    s = ieHwhm2SD(10,2); g = fspecial('gauss',50,s);
%    x = 1:50; x = x - mean(x(:)); mesh(x,x,g/max(g(:))); axis equal
%
% By default, we assume a bivariate Gaussian (gDim = 2)
%
%    g2 = (1/(2*pi*sx*sy))*exp(-(1/2)(x/sx)^2 + (y/sy)^2)
%
%http://en.wikipedia.org/wiki/Multivariate_normal_distribution#Bivariate_ca
%se
%
% N.B. The 1D case has not been tested significantly.
%
%                             ---------------------------
% Notes:
%
% In the 2D case there is an elliptical curve(hx,hy) where the function is
% 1/2. The ellipse is defined from
%
%    0.5   = exp(-(1/2)*(hx/sx)^2 + (hy/sy)^2)
%    ln(2) = (1/2)*(hx/sx)^2 + (hy/sy)^2
%
% We know that (hx,0) is on the contour, so
%    ln(2) = (1/2)*(hx/sx)^2
%    sx = hx / sqrt(2*ln(2))
%
%                             ---------------------------
%
% In the 1D case:  g1 = (1/s sqrt(2pi)) exp(-(x/2s)^2)
%
%   The max is M = 1/s*sqrt(2*pi)
%   The half max occurs at a value, h, where
%
%    0.5            = exp(-(h/2s)^2)
%    ln(0.5)        = -(h/2s)^2
%    sqrt(-ln(0.5)) = h/2s
%    2s sqrt(ln(2)) = h
%
% We calculate the standard deviation in the 1D Gaussian case using a
% slightly different formula
%
%    s = h/(2*sqrt(ln(2));
%
% Copyright ImagEval Consultants, LLC, 2007.

if ieNotDefined('h'), error('Half width half max required'); end
if ieNotDefined('gDim'), gDim = 2; end;

switch gDim
    case 1
        s = h/(2*sqrt(log(2)));
    case 2
        s = h/(sqrt(2*log(2)));
    otherwise
        error('Not implemented for %f dimensional Gaussian',gDim);
end

return;