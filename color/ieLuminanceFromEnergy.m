function lum = ieLuminanceFromEnergy(energy,wave)
% Calculate luminance (cd/m2) and related quantities (lux,lumens,cd) from spectral
% energy
%
%    lum = ieLuminanceFromEnergy(energy,wave)
%
% Purpose:
%   The CIE formula for luminance converts a spectral radiance distribution
%   (W/m2-sr-nm) into luminance (candelas per meter squared, cd/m2). This
%   routine accepts RGB or XW (space-wavelength) formatted inputs. In XW
%   format, the spectral distributions are in the rows of the ENERGY
%   matrix. 
%
%   The formula for luminance and illuminance are the same, differing only
%   in the units of the input. Hence, this routine calculates illuminance
%   (lux) from a spectral irradiance distribution (W/m2-nm).  It also
%   calculates luminous intensity (cd) from spectral radiant intensity
%   (W/sr-nm); finally, it calculates luminous flux (lumens, lm) from
%   spectral power (W/nm).  The pairings are:
%
%      Luminance:         cd/m2  from W/sr-m2-nm
%      Illuminance:         lux  from  W/m2-nm
%      Luminous flux:     lumens from W/nm
%      Luminous intensity:    cd from W/sr-nm.
%
%   To calculate luminance (or illuminance) from a spectral radiance
%   distribution in photons, use ieLuminanceFromPhotons() 
%
% Examples:
%   wave = 400:10:700;
%   tmp = load('crtSPD'); dsp = tmp.d;
%   energy = displayGet(dsp,'whitespd',wave);
%   energy = energy';
%   lum = ieLuminanceFromEnergy(energy,wave)
%
% Online reference:
%  http://www.optics.arizona.edu/Palmer/rpfaq/rpfaq.htm
%
% Copyright ImagEval Consultants, LLC, 2003.

% xwData = ieConvert2XW(energy,wave);
switch vcGetImageFormat(energy,wave)
    case 'RGB'
        xwData = RGB2XWFormat(energy);
    otherwise
        % XW format
        xwData = energy;
end

fName = fullfile(isetRootPath,'data','human','luminosity');
V = ieReadSpectra(fName,wave);

% 683 is the standard factor for conversion when the energy are in Watts.
% The wavelength difference accounts for the wavelength sampling.
if numel(wave) > 1,  dWave = wave(2) - wave(1);
else                 dWave = 10;   disp('10 nm band assumed');
end
lum = 683*(xwData*V) * dWave;

return;


