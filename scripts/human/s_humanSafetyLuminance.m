%% s_humanSafetyLuminance
%
% Sometimes we only have a meter to measure the luminance of a light.  If
% the light is monochromatic, then we can still calculate the safety
% function by converting the monochrome light luminance to radiance.
%
% An example is in here.  For more documentation see s_humanSafety.
%
% See also
%   s_humanSafety

%% Start with a monochromatic light luminance

% Suppose we measure a monochromatic source and it has these parameters
lum     = 200;     % Luminance of the monochromatic source
thisWave    = 405;    % Mean wavelength of the monochromatic source
dLambda = 10;     % Spectral band width

% We convert the luminance to energy
% watts/sr/nm/m2
[radiance,wave] = ieLuminance2Radiance(lum,thisWave,'sd',dLambda); 

% Now read the hazard function (Actinic) of the safety standard.  For more
% information read the comments in s_humanSafety.
fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);

% Convert radiance to irradiance and calculate the hazard for 1 sec
% duration
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,radiance*pi) * dLambda * duration;

% Convert the hazard energy into maximum daily allowable exposure in
% minutes using the formula from the standard.
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)

%% END