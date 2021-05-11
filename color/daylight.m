function [spec, XYZ] = daylight(wave, cct, units)
% Generate a daylight SPD with a correlated color temperature
%
% [SPD, XYZ, wave] = daylight( WAVE, cct )
%
% Generates a daylight/sun spectral power distribution based on a
% correlated color temperature (cct).
%
% SPD : Daylight/sun SPD.
% WAVE: Wavelength vector of SPD.
% TEMP: Correlated color temperatures.
%
% Example:
%   w = 400:700; spd = daylight(w,6500,'energy'); plot(w,spd)
%   w = 400:700; spd = daylight(w,6500,'photons'); plot(w,spd)
%
%   w = 400:700; [spd, XYZ] = daylight(w,[4000 6500],'photons'); plot(w,spd)
%
% See also: blackbody, cct2sun
%
% Copyright Imageval 2010

if ieNotDefined('wave'), wave = 400:10:700; end
if ieNotDefined('units'), units = 'energy'; end
if ieNotDefined('cct'), cct = 6500; end

spec = cct2sun(wave, cct, units);

% Scale so first spectrum is 100 cd/m^2.
units = ieParamFormat(units);
switch units
    case 'photons'
        L = ieLuminanceFromPhotons(spec(:, 1)', wave);
    case 'energy'
        L = ieLuminanceFromEnergy(spec(:, 1)', wave);
end
spec = (spec / L) * 100;

if nargout == 2
    switch units
        case {'photons', 'quanta'}
            XYZ = ieXYZFromPhotons(spec', wave);
        case 'energy'
            XYZ = ieXYZFromEnergy(spec', wave);
    end
end


return
