function spd = cct2sun(wave, cct, units)
% Correlated color temperature to daylight SPD at specified wavelengths
%
%    SPD = cct2sun( wave, cct, [units = energy'] )
%
% Determines daylight/sun spectral power distribution based on correlated
% color temperature. 
%
% wave : Wavelength vector of SPD.
% cct  : Correlated color temperatures. (Can be a vector, but should it?)
% units: Specifies units of returned SPD (relative energy or relative photons)
%
% spd  : Daylight/sun SPD in units of (relative) energy or photons
%
% Reference: 
%    http://en.wikipedia.org/wiki/Standard_illuminant
%    Judd, Macadam, Wyszecki - http://www.opticsinfobase.org/abstract.cfm?URI=josa-54-8-1031
% See also: daylight.m
%
% Examples:
%   wave = 400:5:700; cct = 4000; spd = cct2sun(wave, cct); plot(wave,spd);
%   wave = 400:2:700; cct = 6500; spd = cct2sun(wave, cct, 'photons'); plot(wave,spd);
%   wave = 400:2:700; cct = 6500; spd = cct2sun(wave, cct, 'energy'); plot(wave,spd);
%
%   w = 400:700; spd = cct2sun(w,[4000 6500],'photons'); plot(w,spd)
%
% Last Updated: 08-14-00

if ieNotDefined('wave'),wave = 400:700; end
if ieNotDefined('cct'), error('Correlated color temperature required'); end
if ieNotDefined('units'), units = 'energy'; end

% Calculate the xy chromaticity coordinates.
mask = 1.*(cct>=4000 & cct<7000 ) + 2.*(cct>=7000 & cct<30000);

ind = find(mask == 0, 1);
if (~isempty(ind))
   error('At least one CCT is outside the acceptable range [4000-30000]');
end

% Look this up and put in a reference to the appropriate W&S pages.
xdt = zeros(2,size(cct,2));
xdt(1,:) = -4.6070e9./cct.^3 + 2.9678e6./cct.^2 + 0.09911e3./cct + 0.244063;
xdt(2,:) = -2.0064e9./cct.^3 + 1.9018e6./cct.^2 + 0.24748e3./cct + 0.237040;

% Explain the mask terms.
xd = (mask==1).*xdt(1,:) + (mask==2).*xdt(2,:);
yd = -3.000*xd.^2 + 2.870*xd - 0.275;

% Calculate the CIE SUN weights that will be applied to the CIE sunlight
% basis functions in CIESUN.
M  = zeros(2,size(cct,2));
M(1,:) = (-1.3515 - 1.7703*xd + 5.9114*yd)  ./ ...
   (0.0241 + 0.2562*xd - 0.7341*yd);
M(2,:) = (0.0300 - 31.4424*xd + 30.0717*yd) ./ ...
   (0.0241 + 0.2562*xd - 0.7341*yd);

% Calculate the final daylight SPD.  
% There are currently several daylight basis files in the repository. We
% need to decide on one, and make sure this matches.
dayBasis = ieReadSpectra('cieDaylightBasis',wave);
spd = dayBasis(:,2:3)*M + repmat(dayBasis(:,1),[1 size(cct,2)]);

% Flip to photons/quanta if needed.  Energy or watts would be the
% alternative.
switch lower(units)
    case {'quanta','photons'}
        spd = Energy2Quanta(wave,spd);
    otherwise
end

return;
