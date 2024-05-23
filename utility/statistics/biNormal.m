function g = biNormal(xSpread, ySpread, theta, N)
% Compute bivariate normal function
%
% Syntax:
%   g = biNormal(xSpread, ySpread, [theta], [N])
%
% Description:
%    This does not properly account for a full covariance matrix. It only
%    has different std dev on x and y. But you can rotate the thing. The
%    ordering is (a) build a bivariate normal aligned with (x, y) and
%    scaled by the x and y spreads, (b) rotate the result.
%
%    Examples are located within the code. To access the examples, type
%    'edit biNormal.m' into the Command Window.
%
% Inputs:
%    xSpread - The spread across the x-axis
%    ySpread - The spread across the y-axis
%    theta   - (Optional) The angle of rotation. Default is 0.
%    N       - (Optional) The size of the to-be-calculated gaussian lowpass
%              filter. Default is 128.
%
% Outputs:
%    g       - The resulting image after calculation
%
% Optional key/value pairs:
%    None.
%
% Examples are included within the code.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    12/13/17  jnm  Formatting. Change 2nd example of xSpread to ySpread in
%                   the notDefined section.
%    01/29/18  jnm  Formatting update to match Wiki.

% Examples:
%{
    g = biNormal(5, 10, 0, 128);
    imagesc(g), axis image;
%}
%{
    g = biNormal(5, 10, 45, 128);
    imagesc(g), axis image; 
%}
%{
    g = biNormal(5, 10, 45, 128);
    imagesc(g), axis image; 
%}

if notDefined('xSpread'), error('x sd required'); end
if notDefined('ySpread'), error('y sd required'); end
if notDefined('theta'), theta = 0; end
if notDefined('N'), N = 128; end

if xSpread > 0.5 * N || ySpread > 0.5 * N
    warning('Large spread compared to support %f %f', xSpread, ySpread);
end

xG = fspecial('gauss', [1, N], xSpread);
yG = fspecial('gauss', [N, 1], ySpread);
g = (yG(:) * xG(:)');

if theta ~= 0, g = imrotate(g, theta, 'crop'); end

end