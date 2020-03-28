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

%%  Create a radiance and convert it to irradiance

wave       = 300:700;
radiance   = 10*blackbody(wave,9000);
irradiance = radiance*pi;

% ieNewGraphWin; plot(wave,irradiance);

%% Run the UV hazard safety function

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Safe exposure (hours) for 8 hour period is %.2f minutes\n',exposureMinutes);

%% An example of a light measured in the lab

fname = which('LED405nm.mat');
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
plotRadiance(wave,radiance);
irradiance = pi*radiance;

exposureMinutes = humanUVSafety(irradiance,wave);
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

%% An example of the 385nm light in the OralEye camera

%fname = which('LED385nm.mat');

fname = which('LED405nm.mat');
wave = 300:700;
radiance = ieReadSpectra(fname,wave);
radiance = mean(radiance,2);
plotRadiance(wave,radiance);

irradiance = pi*radiance;
exposureMinutes = humanUVSafety(irradiance,wave);

fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)

% Each exposure is very brief.  So you can safelty take this many exposures
fprintf('For a 30 ms exposure, you can take %d exposures\n',round((exposureMinutes*60)/0.030));

lum405 = ieLuminanceFromEnergy(radiance,wave);
radiance2 = ieLuminance2Radiance(lum405,405,'bin width',dLambda/6); % watts/sr/nm/m2
lst = (wave == 405);

%% Start with a monochromatic light luminance


% Suppose we know the luminance of a 380 nm light with a 10 nm bin width
% lum = 31; wave = 385; dLambda = 3;

% We convert the luminance to energy
dLambda = 4;
radiance2 = ieLuminance2Radiance(lum405,405,'bin width',dLambda); % watts/sr/nm/m2

irradiance = pi*radiance;

exposureMinutes = humanUVSafety(irradiance,wave);

% Conver the hazard energy into maximum daily allowable exposure in minutes
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes)


%%  Plot the Actinic hazard function 

ieNewGraphWin;
mx = max(irradiance(:));
dummy = ieScale(Actinic,1)*mx;
plot(wave,irradiance,'k-',wave,dummy,'r--','linewidth',2);
xlabel('Wave (nm)');
ylabel('Irradiance (watts/m^2');
grid on
legend({'Irradiance','Normalized hazard'});

%%  Near-UV hazard exposure limit
%{
This calculation has no weighting function.  

For times less than 1000 sec, add up the total irradiance
from 315-400 without any hazard function (Equation 4.3a).  Call this E_UVA.
Multiply by time (seconds).  The product should be less than 10,000.

For times exceeding 1000 sec, add up the total irradiance, divide by the
time, and the value must be less than 10 (Equation 4.3b).
%}
