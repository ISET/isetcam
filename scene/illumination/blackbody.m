function [specRad XYZ] = blackbody( wave, temps, unitType , eqWave)
%Generate the spectral power distribution of a blackbody radiator
%
%  [spec XYZ] = blackbody( wave, colortemperature, [unitType = 'energy'], [eqWave = 550] )
%
% The formula for blackbody radiators is computed for an array of color
% temperatures.  The returned values are in W/(m2 nm sr) by default.  If
% you request photon units (unitType = 'photons'), the returned values will
% be in quanta/(m^2 nm sr).
%
% The color temperatures are in degrees Kelvin.
%
% The returned spectra have a luminance on the order of 100 cd/m2.  They
% are scaled so that the radiance at the eqWave value (eqWave default 550)
% are equal.
%
% The typical range of color temperatures for visible light runs from
% roughly 2500 to 10,000 K.   Perceptual differences between these are
% roughly equal in mireds which is inverse to these degree Kelvin
% measurements:
%
% Equal steps of temperature difference in Kelvin are not equal steps of
% perceptual difference.  Rather, they are in equal steps of mireds. A
% good formula for approximating equal perceptual difference is
%
%      perceptual difference is ~ (1/K1)- (1/K2).
%
% Reference:
% http://hyperphysics.phy-astr.gsu.edu/hbase/mod6.html
%
% Examples:
%  wave = 400:10:700;
%  sp = blackbody(wave,5000,'energy')
%  temps = [3000, 5000]; sp = blackbody(wave, temps,'quanta');
%  vcNewGraphWin; plot(wave,sp)
%
%  [sp XYZ] = blackbody(wave,3000:500:8000,'photons',600);
%  vcNewGraphWin; plot(wave,sp)
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('wave'), error('Must define wavelength.'); end
if ieNotDefined('temps'), error('Must define color temperature'); end
if ieNotDefined('unitType'), unitType = 'watts'; end
if ieNotDefined('eqWave'), eqWave = 550; end

% Find index to the wavelength closest to eqWave
[v,idx] = min(abs(wave - eqWave)); %#ok<ASGLU>

% We could check that these are vectors if we had such a utility.  Make
% one, please.
wave = wave(:);
temps = temps(:)';

% Fundamental constants
% h  = vcConstants('h');    %6.626176e-34;	% [J sec]
% c  = vcConstants('c');    % 2.99792458e8;	% [m/sec]
% k =  vcConstants('j');    % 1.380662e-23;	% [J/K], Joules/degree Kelvin

% Other constants specific to the black body radiator formula, and their
% units
c1 = 3.741832e-16;	% [W m^2]
c2 = 1.438786e-2;	% [m K]

% Convert wavelengths from nm to m for use in the formula below.
waveM = wave * 1e-9;

% Apply Planck's Law.  Now here is an obscure piece of code.  Comes from
% DiCarlo at some point in time.  Let's re-write this formula so a normal
% person can read it. It should be basically hV/ (exp(hv/kT) - 1) where T
% are the temps, waveM is the wavelength, and so forth.  Notice that we
% have the fundamental units above, but Jeff put in the needed products
% instead.

% [W/m^3]
specEmit = c1 ./ ( repmat(waveM.^5, [1 length(temps)]) .* (exp(c2./(waveM*temps))-1) );

% [W/(m^2 nm sr)]
specRad  = specEmit * 1e-9 / pi;

% If user requested photons, convert here.
switch lower(unitType)
    case {'watts','energy'}
        % Get data into a plausible range, near 100 cd/m2
        L = ieLuminanceFromEnergy(specRad(:,1)',wave);
        specRad = specRad*(100/L);
        % plot(wave,specRad)
        
        % Equate them all
        s = specRad(idx,1) ./ specRad(idx,:);
        specRad = specRad*diag(s);
        % plot(wave,specRad)
        return;
    case {'photons','quanta'}
        % Photons
        s = specRad(idx,1) ./ specRad(idx,:);
        specRad = specRad*diag(s);
        L = ieLuminanceFromEnergy(specRad(:,1)',wave);
        specRad = specRad*(100/L);
        
        specRad = Energy2Quanta(wave,specRad);
        % plot(wave,specRad)
    otherwise
        error('Unknown unit type.');
end

if nargout == 2
    switch unitType
        case {'photons','quanta'}
            XYZ = ieXYZFromPhotons(specRad',wave);
        case 'energy'
            XYZ = ieXYZFromEnergy(specRad',wave);
    end
end

return;
