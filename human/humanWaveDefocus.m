function D = humanWaveDefocus(wave)
% Defocus in diopters as a function of wavelength
%
%  D = humanWaveDefocus(wave)
%
% wave: wavelength in nanometers
%
% This is a function fit to the data from Bedford and Wyszecki and Wald on
% human chromatic aberration.
%
% Example:
%   wave = 400:10:700;
%   D =  humanDefocus(wave);
%   plot(wave,D); xlabel('Wave (nm)'), ylabel('Diopters'); grid on
%
% Copyright ImagEval Consultants, LLC, 2011.

% Constants for formula to compute defocus in diopters (D) as a function of
% wavelength for human eye.  Need citation, but the curve is in my book.
% Not sure where the formula comes from.
q1 = 1.7312; q2 = 0.63346; q3 = 0.21410;

% This is the human defocus as a function of wavelength.  This formula
% converts the wave in nanometers to wave in microns.  D is in diopters.
D = q1 - (q2./(wave*1e-3 - q3));        
% plot(wave,D); 
% grid; xlabel('Wavelength (nm)'); ylabel('relative defocus (diopters)');

return
