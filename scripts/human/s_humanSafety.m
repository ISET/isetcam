%% s_humanSafety
%
% Calculate the safety of a short wavelength light with respect to
% different standards.
%
% The official safety functions are stored in data/human/safetyStandard.
% The data were taken from 
%  ?IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems.? n.d.
%  Accessed October 5, 2019. https://webstore.iec.ch/publication/7076 
%  J.E. Farrell has a copy of this standard
%
% We load in a radiance (Watts/sr/nm/m2), convert it to irradiance
%
%      Irradiance = Radiance * pi
%
% This was used for the Oral Eye project, but we can not expect that the
% repository will always be on the path.  So for this test we commented out
% that part of the script
%
% See also
%   Oral eye project

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
radiance   = blackbody(wave,3000);
irradiance = radiance*pi;

% ieNewGraphWin; plot(wave,irradiance);

%%  Load the safety function

fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);

% The formula is
%
%    sum Actinic(lambda) irradiance(Lambda) dLambda Time
%

% Units (Watts = Joules/sec)
%     Watts/m2/nm * nm * sec
%     Joules/sec/m2/nm * nm * sec
%     Joules/m2
%
dLambda  = wave(2) - wave(1);
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,irradiance) * dLambda * duration;

% This is the formula from the standard to compute the maximum daily
% allowable exposure 
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)

%% An example of a light measured in the lab

fname = fullfile(isetRootPath,'local','blueLedlight30.mat');
load(fname,'wave','radiance');
radiance = mean(radiance,2);
irradiance = pi*radiance;

fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);
dLambda  = wave(2) - wave(1);
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,irradiance) * dLambda * duration;
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)

%% An example of the 385nm light in the OralEye camera

%{
fname = fullfile(oreyeRootPath,'data','lights','OralEyeBlueLight.mat');
load(fname,'wave','radiance');
radiance = mean(radiance,2);
irradiance = pi*radiance;

fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);
dLambda  = wave(2) - wave(1);
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,irradiance) * dLambda * duration;
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)
%}

%% Start with a monochromatic light luminance

% Suppose we know the luminance of a 380 nm light with a 10 nm bin width
lum = 10; wave = 380; dLambda = 10;

% We convert the luminance to energy
radiance = ieLuminance2Radiance(lum,405,'bin width',dLambda); % watts/sr/nm/m2

% Now read the hazard function (Actinic)
Actinic = ieReadSpectra(fname,wave);

% Convert radiance to irradiance and calculate the hazard for 1 sec
% duration
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,radiance*pi) * dLambda * duration;

% Conver the hazard energy into maximum daily allowable exposure in minutes
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)


%%  Plot the Actinic hazard function 

ieNewGraphWin;
mx = max(irradiance(:));
dummy = ieScale(Actinic,1)*mx;
plot(wave,irradiance,'k-',wave,dummy,'r--','linewidth',2);
xlabel('Wave (nm)');
ylabel('Irradiance (watts/m^2');
grid on
legend({'Irradiance','Normalized hazard'});

%%
