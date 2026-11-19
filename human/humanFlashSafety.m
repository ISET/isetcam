function results = humanFlashSafety(spectralRadiance,wave,duration,sourceAngle)
% Compute IEC 62471:2006 retinal exposure margins for one optical flash.
%
% Syntax
%   results = humanFlashSafety(spectralRadiance,wave,duration)
%   results = humanFlashSafety(spectralRadiance,wave,duration,sourceAngle)
%
% Inputs
%   spectralRadiance - Pulse-average spectral radiance in W/(m^2 sr nm).
%       For a nonrectangular pulse, use the time integral of spectral
%       radiance over the pulse divided by its duration. For a pulsed-lamp
%       measurement, average radiance over a 1.7 mrad full-angle field of
%       view in the direction and position being assessed (IEC clause 6.2).
%   wave - Strictly increasing wavelengths in nm, one per radiance sample.
%       Supply measured samples covering the relevant emission bands. The
%       calculation assigns zero contribution outside the supplied range.
%   duration - Optical pulse width in seconds between the half-maximum
%       points. This calculation covers a single pulse, from 10 us up to
%       but excluding 250 ms (IEC clauses 3.30, 4.3.5 and 6.2).
%   sourceAngle - Apparent angular subtense of the source in radians for
%       the thermal limit. A scalar angle is bounded to [0.0017, 0.1]
%       rad according to clause 4.2.2. For an oblong source, supply
%       the mean of its two individually bounded angular dimensions.
%       The default (0.1 rad) gives the lowest thermal limit for the
%       supplied radiance.
%
% Returns
%   results - 
%          results.duration
%          results.sourceAngle
%          substructs: (blueLight and retinalThermal). 
%       Each has weightedRadiance in W/(m^2 sr), dose and limit in
%       J/(m^2 sr), fractionOfLimit (dose divided by limit),
%       marginFactor (limit divided by dose), and withinLimit. A
%       marginFactor greater than 1 is below the limit. 
%
% Description
%   For both hazards, linearly interpolate the supplied spectrum and
%   the ISETCam Table 4.2 weights at the original sample wavelengths
%   and at 1 nm intervals within the overlap of the measurement and
%   hazard band. Include the overlap endpoints, then integrate the
%   product by trapezoid and multiply by the pulse width to get a
%   weighted dose. The blue-light weighting B(lambda) spans 300-700 nm
%   and its dose limit is 1e6 J/(m^2 sr) (Eq. 4.5a). The thermal
%   weighting R(lambda) spans 380-1400 nm and its radiance limit is
%   50000/(sourceAngle * duration^0.25) W/(m^2 sr) (Eq. 4.9). Multiply
%   the thermal limit by duration for the dose comparison.
%
% See also
%   s_safetyFlash, s_safetyStandards, humanUVSafety, ieReadSpectra

if nargin < 4, sourceAngle = 0.1; end

validateattributes(wave,{'numeric'},{'vector','real','finite','positive'}, ...
    mfilename,'wave');
validateattributes(spectralRadiance,{'numeric'}, ...
    {'vector','real','finite','nonnegative','numel',numel(wave)}, ...
    mfilename,'spectralRadiance');
validateattributes(duration,{'numeric'}, ...
    {'scalar','real','finite','>=',1e-5,'<',0.25},mfilename,'duration');
validateattributes(sourceAngle,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'sourceAngle');

wave = double(wave(:));
spectralRadiance = double(spectralRadiance(:));
duration = double(duration);
if numel(wave) < 2 || any(diff(wave) <= 0)
    error('humanFlashSafety:InvalidWavelengths', ...
        'Supply at least two strictly increasing wavelength samples.');
end

sourceAngle = min(max(double(sourceAngle),0.0017),0.1);
dataDir = fullfile(isetRootPath,'data','safetyStandards');
blueRadiance = weightedRadiance(wave,spectralRadiance, ...
    fullfile(dataDir,'blueLightHazard.mat'),[300 700]);
thermalRadiance = weightedRadiance(wave,spectralRadiance, ...
    fullfile(dataDir,'burnHazard.mat'),[380 1400]);
thermalRadianceLimit = 50000/(sourceAngle * duration^0.25);

results.duration = duration;
results.sourceAngle = sourceAngle;
results.blueLight = exposureMargin(blueRadiance,duration,1e6);
results.retinalThermal = exposureMargin(thermalRadiance,duration, ...
    thermalRadianceLimit * duration);
end

function level = weightedRadiance(wave,spectralRadiance,weightFile,band)
lower = max(wave(1),band(1));
upper = min(wave(end),band(2));
if lower >= upper
    level = 0;
    return;
end

measuredWave = wave(wave > lower & wave < upper);
integrationWave = unique([lower; measuredWave; (ceil(lower):floor(upper))'; upper]);
sampledRadiance = interp1(wave,spectralRadiance,integrationWave,'linear');
weights = ieReadSpectra(weightFile,integrationWave);
level = trapz(integrationWave,sampledRadiance .* weights);
end

%% Helper - exposure margin

function hazard = exposureMargin(weightedLevel,duration,doseLimit)
hazard.weightedRadiance = weightedLevel;
hazard.dose = duration * weightedLevel;
hazard.limit = doseLimit;
hazard.fractionOfLimit = hazard.dose / doseLimit;
hazard.marginFactor = doseLimit / hazard.dose;
hazard.withinLimit = hazard.dose <= doseLimit;
end
