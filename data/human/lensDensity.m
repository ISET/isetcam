%
%
% Load this from the PsychToolBox
% load('den_lens_ssf');

wavelength = 390:830;
data = den_lens_ssf;
comment = 'Lens density as a function of wavelength from PsychToolBox';
fName = fullfile(isetRootPath,'data','human','lensDensity.mat');
fName = ieSaveSpectralFile(wavelength,data,comment,fName);
