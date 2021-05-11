function [X, U] = mlCoordinates(x1, x2, n, lambda, type)
%Create  sampling grids for Wigner phase space (PS) diagram.
%
%    [X,U] = mlCoordinates(x1,x2,n,lambda,type)
%
% x1,x2:   minimum and maximum positions of the spatial dimension
% n:       the refractive index of the medium
% lambda:  the wavelength of the incident light in the medium
% type:    angle or frequency
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2005.


% Programming Notes
%   We should allow an option of sending in nPoints instead of fixing it
%   inside of this routine.

% The code here was included to choose a sampling rate that would work for
% the Wigner transform case.  We are doing only ray trace at this point, so
% we felt it was safe to just set the number of sample points and ignore
% any sampling/aliasing issues for now.  If we put back the Wigner case, we
% need to reconsider this code.
% %
% % The spatial sampling rate for PS calculation is set here.  The number of
% % samples can get pretty large and slow down the calculation.  For a 8
% % micron pixel, simulated at 500 nm, the grid is about 800 x 800
% % k = 2*pi/lambda;
% % pMax = k;
% % pSample = 2*pMax;
% % xSample = 1/pSample;
% %
% % % We need a better way to decide on the number of points.  We chose this
% % % (divide by 2) by examining some results.  But we need to return to this
% % % issue.
% % nPoints = round((abs(x1)+abs(x2))/xSample);
% % nPoints = nPoints - mod(nPoints,2);
% %

% We make this odd so 0 is always one of the samples.
nPoints = 255;

% Create the x and p sample values
x = linspace(x1, x2, nPoints);
y = 0;

% We set this to .99 to make sure that the angle coordinate is never out of
% the bounds of the sin function.
p = linspace(-n*0.99, n*0.99, nPoints);
q = 0;

switch lower(type)
    case ('angle')
        u = p;
        v = q;
    case ('frequency')
        u = p * pMax;
        v = q * pMax;
end

[X, U] = meshgrid(x, u);

return;
