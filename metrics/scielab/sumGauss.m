function g = sumGauss(params, dimension)
% Calculated a weighted sum of three Gaussians, used in SCIELAB
%
%    g = sumGauss(params, dimension)
%
% params:
%    [support, halfwidth1, weight1, halfwidth2, weight2, halfwidth3, weight3]
%
% dimension: determines whether required sum of gaussians is 1-D or 2-D.
%            1 => 1-D; 2 => 2-D.
%            Default is 1.
%
% See scPrepareFilters, gauss, gauss2
%
% Copyright ImagEval Consultants, LLC, 2003.

%{
support = 64;
halfwidth1 = 5;  weight1 = 0.2;
halfwidth2 = 10; weight2 = 0.2;
halfwidth3 = 20; weight3 = 0.5;
params = [support, ...
   halfwidth1, weight1, ...
   halfwidth2, weight2, ...
   halfwidth3, weight3];
dimension = 2;
g = sumGauss(params, dimension);
X = (1:support) - support/2;
vcNewGraphWin; mesh(X, X, g); grid on;
%}
if ieNotDefined('params'), error('params required'); end
if ieNotDefined('dimension'), dimension = 1; end

width = ceil(params(1));
nGauss = (length(params)-1)/2;

if (dimension==2),  g = zeros(width, width);
else,               g = zeros(1, width);
end

% Add up the Gaussians.  These calls could be made using fspecial and the
% ieHwhm2SD function as well.  But we leave these here for now because in
% the future we might use oriented Gaussians.
for ii=1:nGauss
    halfwidth = params(2*ii);
    weight    = params(2*ii + 1);
    if (dimension==2)
        g0 = gauss2(halfwidth, width, halfwidth, width);
    else
        g0 = gauss(halfwidth, width);
    end
    g = g + weight * g0;
end

% Make sure the summed Gaussians equals precisely to 1.
g = g/sum(g(:));

return;