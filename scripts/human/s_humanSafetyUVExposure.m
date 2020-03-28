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

%{ 
% Safety Notes
%
% Plot the three different functions and explain them here
% Make sure the formulae for hazards are implemented for
%
%    Actinic UV hazard exposure limit skin and eye (4.3.1)
%    Near UV hazard limit for the eye (4.3.2)
%    Retinal blue light hazard exposure (4.3.3)
%    Retinal blue light small source (4.3.4)
%    Retinal thermal hazard (4.3.5)
%    Retinal theermal hazard for weak visual stimulus (4.3.6)
%    Infrared exposure for the eye (4.3.7)
%    Thermal hazard for the skin (4.3.8)
%}

%{
We checked two ways if radiance -> irradiance is multiplied by 2pi or 1pi

From: Peter B. Catrysse <pcatryss@stanford.edu>
Sent: Wednesday, August 21, 2019 11:02 AM
To: Joyce Eileen Farrell <jefarrel@stanford.edu>
Subject: RE: spectroradiometric measurements

Hello Joyce,

 It is definitely pi. 
 There is 2*pi solid angle for the hemisphere, but when you integrate 
 you end up getting pi as factor.

See you next week,

Peter

From: Joyce Eileen Farrell [mailto:jefarrel@stanford.edu] 
Sent: Tuesday, August 20, 2019 10:58 PM
To: Peter Bert Catrysse <pcatryss@stanford.edu>
Subject: Re: spectroradiometric measurements

Hi Peter,

Thanks so very much for giving me the conversion from radiance to
irradiance. 

is it 
E = pi*L/R (where E is irradiance, L is radiance and R is reflectance)
or
E=2pi*L/R

See also this exchange

https://physics.stackexchange.com/questions/116596/convert-units-for-spectral-irradiance

The person multiplies b6000 by pi, not 2pi
%}

%% An example of a light measured in the lab

wave = 300:770;
fname = which('LED405nm.mat');
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
lum405 = ieLuminanceFromEnergy(radiance,wave);
plotRadiance(wave,radiance);
irradiance = pi*radiance;

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

%% An example of the 385nm light in the OralEye camera

fname = which('LED385nm.mat');
wave = 300:700;
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
plotRadiance(wave,radiance);

irradiance = pi*radiance;
exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

% Each exposure is very brief.  So you can safelty take this many exposures
fprintf('For a 30 ms exposure, you can take %d exposures in an eight hour period.\n',round((exposureMinutes*60)/0.030));

%%  The mean daylight we measured in California

wave       = 300:700;
[radiance,wave] = ieReadSpectra('DaylightPsychBldg.mat',wave);
plotRadiance(wave,radiance);

% Convert radiance to irradiance
irradiance = radiance*pi;

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Safe exposure (hours) for 8 hour period is %.2f minutes (%.2f hours)\n',exposureMinutes,exposureMinutes/60);

%% If you only know the luminance of an LED (monochromatic) and its bandwidth (s.d.)

lum = lum405;   % cd/m2, luminance of the 405 LED
thisWave = 405; % nm, center wavelength of the LED
bandwidth = 15; % nm, Gaussian standard deviation, FW at roughly 1/2 of the max
[estRadiance,wave] = ieLuminance2Radiance(lum,thisWave,'sd',bandwidth); 
plot(wave,radiance,'--',wave,estRadiance,'o');
legend({'meas rad','est rad'})

ieLuminanceFromEnergy(estRadiance,wave)
ieLuminanceFromEnergy(radiance,wave)

irradiance = pi*estRadiance;
exposureMinutes = humanUVSafety(irradiance,wave);

% Conver the hazard energy into maximum daily allowable exposure in minutes
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)
fprintf('For a 30 ms exposure, you can take %d exposures in an eight hour period.\n',round((exposureMinutes*60)/0.030));

%%
