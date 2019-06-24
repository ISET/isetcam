% s_createGaussianFilters
%
%  Create a set of filters for use in a simulated camera.  In this case, we
%  use sensorColorFilter to build a set of Gaussian filters at different
%  center wavelengths and widths.
%
%  These functions can also be used as basis functions for estimating a
%  smooth camera filter fit to data.  
%
% Wandell
%
% See also
%   s_arriSensorEstimation.m
%

%{
% Old notes for plethysmograph sensor
  isosbestic      = [500,529,545,570,584];
  non-isosbestic  = [517 560 577 595]; 
  wavelength = 480:4:900; 
  cPos = [500, 529, 550, 560, 595]; 
  width = [20,20,20,20,20];
  data = sensorColorFilter(cfType,wavelength, cPos, width);
%}

% Gaussian type:
cfType = 'gaussian'; 
wavelength = 400:10:700; 
cPos       = 400:40:700; 
width      = ones(size(cPos))*30;

cFilters = sensorColorFilter(cfType, wavelength, cPos, width);
ieNewGraphWin;
plot(wavelength,cFilters);

%%
d.data = cFilters;
d.wavelength = wavelength;
d.filterNames = ['a', 'b', 'c', 'd', 'e'];
d.comment = 'Gaussian filters created by s_createGaussianFilters';
savedFile = ieSaveColorFilter(d,fullfile(isetRootPath,'local','gFiltersDeleteMe.mat'));

%%
newFilters = ieReadColorFilter(wavelength,savedFile);
ieNewGraphWin;
plot(wavelength,newFilters);

%% End    
 