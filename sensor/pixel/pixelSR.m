function SR = pixelSR(pixel)
% Pixel response spectral responsivity (SR) as a function of wavelength
%
%     SR = pixelSR(pixel)
%
% The SR measure has units of (pixel volts)/(irradiance watt).  The
% measurement is basically the same as spectral quantum efficiency, but
% measured with respect to energy of the irradiance rather than photons.
%
% The relationship between the two is given by Planck's law
%
%     SR(lambda) = (lambda*q)/(h*c) * QE(lambda);
%
% where q is the charge/electron, h is Planck's constant, c is the speed of
% light, lambda is the wavelength of the in put, and QE is the spectral
% quantum efficiency.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Various physical constants are needed.
q = vcConstants('q');
h = vcConstants('h'); 
c = vcConstants('c');

QE      = pixelGet(pixel,'spectralQE');     % e-/ph
lambda  = pixelGet(pixel,'wave')*(10^-9);   % Wavelength in meters

% First term is energy at each wavelength (watts).  QE multiplies to give
% the volts/watt
SR = (lambda(:)*q)/(h*c) .* QE(:);

return