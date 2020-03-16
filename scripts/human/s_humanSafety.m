%% s_humanSafety
%
% How to calculate the safety of a short wavelength light with respect to
% different standards.
%
% The official safety functions are stored in data/human/safetyStandard
% The data were taken from ?IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems.? n.d. Accessed October 5, 2019. https://webstore.iec.ch/publication/7076
% J.E. Farrell has a copy of this standard
%
% We load in a radiance (Watts/sr/nm/m2), we convert that to irradiance for
% a hemifield (2*pi/sr), so
%
%      Irradiance = Radiance * 2pi
%
% We need check if it is 2pi or 1pi
%
% This was used for the Oral Eye project, but we can not expect that the
% repository will always be on the path.  So for this test we commented out
% that part of the script
%
% See also
%   oral eye project

%%  Create a light and convert it to irradiance

wave       = 300:700;
radiance   = blackbody(wave,3000);
irradiance = radiance*2*pi;

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

% From the standards
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)

%% An example of a light measured in the lab
fname = fullfile(isetRootPath,'local','blueLedlight30.mat');
load(fname,'wave','radiance');
radiance = mean(radiance,2);
irradiance = 2*pi*radiance;

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
irradiance = 2*pi*radiance;

fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);
dLambda  = wave(2) - wave(1);
duration = 1;                  % Seconds
hazardEnergy = dot(Actinic,irradiance) * dLambda * duration;
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)
%}

%%
ieNewGraphWin;
mx = max(irradiance(:));
dummy = ieScale(Actinic,1)*mx;
plot(wave,irradiance,'k-',wave,dummy,'r--','linewidth',2);
xlabel('Wave (nm)');
ylabel('Irradiance (watts/m^2');
grid on
legend({'Irradiance','Normalized hazard'});

%%
