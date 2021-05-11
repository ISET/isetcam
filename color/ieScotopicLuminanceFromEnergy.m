function lum = ieScotopicLuminanceFromEnergy(energy, wave)
% Compute the scotopic (rod) luminance from spectral energy
%
%  lum = ieScotopicLuminanceFromEnergy(energy,wave)
%
% Purpose:
%   The CIE scotopic luminance function describes wavelength sensitivity
%   of the rod system.  This is the system we use under low light
%   conditions.  The cone system is used under moderate to bright light
%   conditions and is called the photopic system.
%
%   The energy data format can be either XW or RGB.  WAVE describes the
%   wavelength samples.
%
%   The CIE defines a formula to compute scotopic luminance from the spectral radiance
%   distribution (energy).
%
%       scotopicLuminance = Km * (xwData*Vprime) * deltaLambda;
%
%   xwData are the space-wavelength representation of the signal (energy).
%
%   Km is a scale factor, chosen so that a  blackbody radiator at the
%   freezing temperature of platinum has 60 scotopic candelas per square
%   centimeter.  (Wyszecki and Stiles pp. 377-378 and also p. 384, is 1745.
%   By comparison, the scale factor for photopic luminance is 683).
%
%   Vprime is the scotopic luminance function
%   deltaLambda is the wavelength sampling interval.
%
%
% Examples:
%   wave = 400:10:700;
%   tmp = load('crtSPD'); dsp = tmp.d;
%   energy = displayGet(dsp,'spd',wave);
%   energy = energy';
%   energy = [1,1,1]*energy;
%   lum = ieScotopicLuminanceFromEnergy(energy,wave)
%
% Copyright ImagEval Consultants, LLC, 2003.

% xwData = ieConvert2XW(energy,wave);
switch vcGetImageFormat(energy, wave)
    case 'RGB'
        xwData = RGB2XWFormat(energy);
    otherwise
        % XW format
        xwData = energy;
end

fName = fullfile(isetRootPath, 'data', 'human', 'rods.mat');
Vprime = ieReadSpectra(fName, wave);

if numel(wave) > 1, dWave = wave(2) - wave(1);
else dWave = 10;
    disp('10 nm band assumed');
end
lum = 1745 * (xwData * Vprime) * dWave;

return;
