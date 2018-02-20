function [lum, rg, by, positions] = poirsonSpatioChromatic(sampPerDeg,dimension)
% Pattern-color separable spatial filters from Poirson & Wandell (1993)
%
% [lum, rg, by, positions] = poirsonSpatioChromatic([sampPerDeg =241],[dimension = 2])
%
%  These filters are fitted spatial response, formed by taking the weighted
%  sum of two or three Gaussians. 
%
% Parameters
%   sampPerDeg: filter sampling resolution (default=241 samps/deg)
%   dimension:  filter for 1D or 2D format (default = 2) 
%
% See the Spatial-CIELAB implementation for other related ideas.
%
% Examples:
%  [lum, rg, by, x]  = poirsonSpatioChromatic([],1);
%  plot(x,lum,'k-',x,rg,'r--',x,by,'b:'); xlabel('Position (deg)')
%  grid on
%
%  [lum, rg, by, x]  = poirsonSpatioChromatic(120,2);
%  mesh(x,x,lum); xlabel('Position (deg)'); ylabel('Position (deg)')
%  mesh(x,x,by);
%
%  To compute the spatial MTF of these filters compute
%  clf
%  [lum, rg, by, x]  = poirsonSpatioChromatic(241,1);
%  lumMTF = abs(fft(lum)); plot(lumMTF)
%  minFreq = 1/(max(x) - min(x));
%  freq = [1:length(x)]*minFreq;
%  l = (freq < 60);
%  plot(freq(l),lumMTF(l)); grid on
%
%  For 2D plots some fftshifting is required
%  [lum, rg, by, x]  = poirsonSpatioChromatic(241,2);
%  rgMTF = ifftshift(abs(fft2(fftshift(rg)))); mesh(rgMTF)
%  minFreq = 1/(max(x) - min(x));
%  freq = [1:length(x)]*minFreq; freq = freq - (max(freq)/2);
%  [X,Y] = meshgrid(freq,freq);
%  clf; mesh(X,Y,rgMTF);
%  set(gca,'xlim',[-40 40],'ylim',[-40 40]); 
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('sampPerDeg'),sampPerDeg = 241; end
if ieNotDefined('dimension'), dimension = 2; end

% The filters are the weighted sum of two or three Gaussian functions.
% These variables contain the parameters for generating the filters,
% They represent the Gaussians in the format:
%     [halfwidth weight halfwidth weight ...]
% The halfwidths are in degrees of visual angle.
x1 = [0.05      0.9207    0.225    0.105    7.0   -0.1080];
x2 = [0.0685    0.5310    0.826    0.33];
x3 = [0.0920    0.4877    0.6451    0.3711];

% Convert the unit of halfwidths from visual angle to pixels.
x1([1 3 5]) = x1([1 3 5]) * sampPerDeg;
x2([1 3]) = x2([1 3]) * sampPerDeg;
x3([1 3]) = x3([1 3]) * sampPerDeg;

% Limit the width of filters to 1 degree visual angle, and 
% odd number of sampling points (so that the Gaussians are symmetric.
width = ceil(sampPerDeg/2) * 2 - 1;

% Generate the filters
lum = sumGauss([width x1], dimension);
rg =  sumGauss([width x2], dimension);
by =  sumGauss([width x3], dimension);

% make sure the filters sum to 1
lum = lum/sum(lum(:));
rg  = rg/sum(rg(:));
by  = by/sum(by(:));

if nargout == 4
    centerPosition = (width+1)/2;
    positions = ([1:width] - centerPosition)*(1/sampPerDeg);
end

return;