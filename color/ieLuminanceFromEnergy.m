function lum = ieLuminanceFromEnergy(energy, wave, varargin)
% Calculate luminance (cd/m2) and related quantities (lux,lumens,cd) from spectral
% energy
%
% Synopsis
%    lum = ieLuminanceFromEnergy(energy,wave,varargin)
%
% Input
%   energy:   watts/sr/nm/m2  (a vector, or a matrix XW format)
%   wave:     Wavelength samples (a vector)
%
% Optional key/val pairs
%  bin width:  Wavelength bin width when there is a monochromatic input
%              (10nm default)
%
% Returns
%  lum:   Luminance in cd/m2
%
% Description:
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
%
% Online reference:
%  https://wp.optics.arizona.edu/jpalmer/radiometry/radiometry-and-photometry-faq/
%
% See also
%  ieLuminance2Radiance, ieLuminanceFromPhotons

% Examples:
%{
wave = 400:10:700;
dsp = displayCreate;
energy = displayGet(dsp,'whitespd',wave);
energy = energy';
lum = ieLuminanceFromEnergy(energy,wave)
%}

%%
p = inputParser;
varargin = ieParamFormat(varargin);
p.addRequired('energy', @isnumeric);
p.addRequired('wave', @isnumeric);
p.addParameter('binwidth', 10, @isnumeric);

p.parse(energy, wave, varargin{:});
binwidth = p.Results.binwidth;

%%

% xwData = ieConvert2XW(energy,wave);
switch vcGetImageFormat(energy, wave)
    case 'RGB'
        xwData = RGB2XWFormat(energy);
    otherwise
        % XW format
        xwData = energy;
end

fName = fullfile(isetRootPath, 'data', 'human', 'luminosity');
V = ieReadSpectra(fName, wave);
% ieNewGraphWin; plot(wave,V);  % The luminance curve

% 683 is the standard factor for conversion when the energy are in Watts.
% The wavelength difference accounts for the wavelength sampling.
if numel(wave) > 1, binwidth = wave(2) - wave(1);
else, fprintf('%d nm bandwidth\n', binwidth);
end

% The luminance formula.
if size(xwData, 1) == 1 || size(xwData, 2) == 1
    % xwData can be a matrix, I suppose.  User better check that it is XW
    % format.
    lum = 683 * dot(xwData, V) * binwidth;

else
    % If vectors, xwData and V are not always rows or columns, so we use
    % the dot() formula  rather than multiplying.
    lum = 683 * xwData * V * binwidth;
end

% Compare the luminance and energy data
% ieNewGraphWin; semilogy(wave,V,'--',wave,xwData,'o');

end
