function macbethChart = macbethReadReflectance(wave,patchList)
% Read the macbeth surface reflectances into the standard format
%
% Synopsis
%   macbethChart = macbethReadReflectance(wave,patchList);
%
% The returned variable has the reflectances in the columns but according
% to the ordering used in vcimage
%
% The gray series is in macbethChart(:,4:4:end).
%
% The upper left corner (:,1) is brown, the upper right (:,21) is cyan
% The third row is Blue, green, red, yellow, magenta, light blue
%
% The examples and tutorials calculat images and other values with the MCC
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:
%   t_SurfaceModels and macbethChartCreate

% Examples:
%{
   wave = 400:10:700;
   macbethReflectance = macbethReadReflectance(wave);
   plot(wave,macbethReflectance), xlabel('Wavelength (nm)')
   ylabel('Reflectance'); grid on
%}

if ieNotDefined('wave'), wave = (400:700); end
if ieNotDefined('patchList'), patchList = 1:24; end

% Stored in data/surfaces/reflectances
fName = which('macbethChart.mat');

macbethChart = ieReadSpectra(fName,wave);

macbethChart = macbethChart(:,patchList);

end


