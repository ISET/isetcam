function D = humanWaveDefocus(wave)
% Defocus in diopters as a function of wavelength
%
% Syntax:
%   D = humanWaveDefocus(wave)
%
% Description:
%    This is a function fit to the data from Bedford and Wyszecki and Wald
%    on human chromatic aberration.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanWaveDefocus.m' into the Command Window.
%
% Inputs:
%    wave - Vector. Wavelength vector, in nanometers.
%
% Outputs:
%    D    - Vector. Defocus vector.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/11       Copyright ImagEval Consultants, LLC, 2011.
%    06/28/18  jnm  Formatting

% Example:
%{
    wave = 400:10:700;
    D = humanWaveDefocus(wave);
    vcNewGraphWin;
    plot(wave, D);
    xlabel('Wave (nm)')
    ylabel('Diopters');
    grid on
%}

% Constants for formula to compute defocus in diopters (D) as a function of
% wavelength for human eye. From 
% Larry N. Thibos, Ming Ye, Xiaoxiao Zhang, and Arthur Bradley, 
% "The chromatic eye: a new reduced-eye model of ocular chromatic aberration 
% in humans," Appl. Opt. 31, 3594-3600 (1992)
q1 = 1.7312;
q2 = 0.63346;
q3 = 0.21410;

% This is the human defocus as a function of wavelength. This formula
% converts the wave in nanometers to wave in microns. D is in diopters.
D = q1 - (q2 ./ (wave * 1e-3 - q3));

% plot(wave, D);
% grid;
% xlabel('Wavelength (nm)');
% ylabel('relative defocus (diopters)');

return
