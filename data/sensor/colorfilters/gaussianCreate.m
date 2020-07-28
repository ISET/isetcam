% s_createGaussianFilters
% Deprecated
%
%  Create a set of filters for use in a simulated camera

% Gaussian type:
cfType = 'gaussian'; 
% isosbestic = [500,529,545,570,584];
% non-isosbestic     = [517 560 577 595]; 

wavelength = [480:4:900]; cPos = [500, 529, 550, 560, 595]; width = [20,20,20,20,20];
data = sensorColorFilter(cfType,wavelength, cPos, width);

plot(wavelength,data);

filterNames = ['a', 'b', 'c', 'd', 'e'];
comment = 'Gaussian filters created by s_createGaussianFilters';
cd 'C:\Users\joyce\Documents\Matlab\SVN\iset-4.0\data\sensor\colorfilters';
save fiveGaussians comment data wavelength filterNames; 

load('fiveGaussians.mat')
plot(wavelength,data);
filterNames

              
 