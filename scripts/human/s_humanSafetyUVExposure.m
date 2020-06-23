%% s_humanSafetyUVExposure
%
% Calculate the safety of UV lights for eye and skin exposure.
%
% The safety function curves used in this and related calculations are
% stored in data/human/safetyStandard.
%
%   Actinic         - UV hazard for skin and eye safety The limits for
%                     exposure to ultraviolet radiation incident upon the
%                     unprotected skin or eye (4.3.1 and 4.3.2)  
%
% There are two other types of safety calculations that we include in
% related scripts
%
%   blueLightHazard - Eye (retinal) safety (retinal photochemical injury
%                     from chronic blue-light exposure).  There are
%                     different functions for large and small field lights
%                     (4.3.3 and 4.3.4)
%   burnHazard      - Retinal thermal injury (4.3.5 and 4.3.6)
%
% The data for the safety function curves were taken from this paper
%
%  ?IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems.? n.d.
%  Accessed October 5, 2019. https://webstore.iec.ch/publication/7076 
%  J.E. Farrell has a copy of this standard
%
% Notes:   Near UV is also called UV-A and is 315-400nm.
%
% Calculations
%  We load in a radiance (Watts/sr/nm/m2), convert it to irradiance
%
%      Irradiance = Radiance * pi
%
% See also
% 

%% General parameters
wave = 300:700;

%% An example of a light measured in the lab
fname = which('LED405nm.mat');
radiance = ieReadSpectra(fname,wave);
ledRadiance = mean(radiance,2);
ledRadiance(wave > 500) = 0;  % Only noise was measured above 500 nm

lum405 = ieLuminanceFromEnergy(ledRadiance,wave);
plotRadiance(wave,ledRadiance);
irradiance = pi*ledRadiance;

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

%% An example of the 385nm light in the OralEye camera

fname = which('LED385nm.mat');
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
plotRadiance(wave,radiance);

irradiance = pi*radiance;
exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

% Each exposure is very brief.  So you can safelty take this many exposures
fprintf('For a 30 ms exposure, you can take %d exposures in an eight hour period.\n',round((exposureMinutes*60)/0.030));

%%  The mean daylight we measured in California

[radiance,wave] = ieReadSpectra('DaylightPsychBldg.mat',wave);
plotRadiance(wave,radiance);

% Convert radiance to irradiance
irradiance = radiance*pi;

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Safe exposure (hours) for 8 hour period is %.2f minutes (%.2f hours)\n',exposureMinutes,exposureMinutes/60);

%% If you only know the luminance of an LED (monochromatic) and its bandwidth (s.d.)

% The band width matters a lot for matching the curves.  The luminance
% always matches correctly.
lum       = lum405;  % cd/m2, luminance of the 405 LED
thisWave  = 405;     % nm, center wavelength of the LED
bandwidth = 12;      % nm, Gaussian standard deviation, FW at roughly 1/2 of the max
[estRadiance,estWave] = ieLuminance2Radiance(lum,thisWave,'sd',bandwidth); 
plotRadiance(estWave,estRadiance);

% Check the luminance match
assert(ieLuminanceFromEnergy(estRadiance,estWave) - lum405 < 1e-10)

% Compare the curves
ieNewGraphWin;
plot(estWave,estRadiance,'o',wave,ledRadiance,'x');
grid on; xlabel('Wave'); ylabel('Energy');
legend({'estimated','measured'});

% Calculate the safety
irradiance = pi*estRadiance;
exposureMinutes = humanUVSafety(irradiance,estWave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)
fprintf('For a 30 ms exposure, you can take %d exposures in an eight hour period.\n',round((exposureMinutes*60)/0.030));

%% Now check the other safety metric from Section 4.3.2

fname = which('LED385nm.mat');
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);

irradiance = pi*radiance;
duration = 8;   % Secs
safe = humanUVSafety(irradiance,wave,'method','eye','duration',duration);

if safe
    fprintf('Safe at a duration of %d secs\n',duration);
else
    fprintf('Not safe at a duration of %d secs\n',duration);
end

%%  Blue light hazard calculation
fname = which('LED405nm.mat');
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
plotRadiance(wave,radiance);

duration = 8*60*60;   % Secs
safe = humanUVSafety(radiance,wave,'method','blue hazard','duration',duration);

if safe
    fprintf('Blue hazard: Safe at a duration of %d secs\n',duration);
else
    fprintf('Blue hazard: Not safe at a duration of %d secs\n',duration);
end

%% This is an extremely bright blackbody with a lot of short wave energy

radiance = blackbody(wave,9000)*1e4;
plotRadiance(wave,radiance);

duration = 1000;   % Secs
safe = humanUVSafety(radiance,wave,'method','blue hazard','duration',duration);

if safe
    fprintf('Blue hazard: Safe at a duration of %d secs\n',duration);
else
    fprintf('Blue hazard: Not safe at a duration of %d secs\n',duration);
end

%%