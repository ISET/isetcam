%% s_HumanOptics
%
% Make a mesh plot of the human optical transfer function.  Note that some
% values are negative, which indicates that some of the harmonics are
% imaged in the wrong (negative) phase.  This is called spurious
% resolution.
%
% This function is also used in teaching to illustrate the OTF at different
% wavelengths.
%
% We are shifting these kinds of calculations to the ISETBio code
% based on the wavefront sensor tools.  Still some checking and
% comparisons to do. (July, 2023)
%
% See also: 
%   plotOI, s_HumanLSF
%

%%
ieInit
ieNewGraphWin([],'tall');
tiledlayout(3,1);

%% OTF
wave = 400:10:700;       % nanometer
sampleSF = 0:0.5:50;     % cyc/deg
p  = 0.0015;  % Pupil radius (m)
D0 = 60;      % Dioptric power of human lens

otf = humanCore(wave,sampleSF,p,D0);

%% Plot the amplitude of the optical transfer function.
nexttile;
mesh(sampleSF,wave,otf)
view(32.5,14);
xlabel('Spatial freq cy/deg');
ylabel('Wavelength (nm)');
zlabel('OTF')

%% Plot graphs of a few sample wavelengths
% The effect of chromatic aberration (defocus in the short) is quite
% apparent in these graphs.

nexttile;
waveList = [420 550 670];
cList = {'b-','g-','r-'};
for ii=1:length(waveList)
    plot(sampleSF,otf(ieFindWaveIndex(wave,waveList(ii)),:),cList{ii});
    hold on
end
grid on

xlabel('Spatial freq cy/deg');
ylabel('OTF value');
legend({'420 nm','550 nm','670 nm'})

%% Compare with Thibos wavefront.

oi = oiCreate('wvf human',3);  % 3 mm pupil
oi = oiSet(oi,'optics fnumber',5.7);
oi = oiSet(oi,'fov',1);

OTF420 = abs(oiGet(oi,'optics otf',420)); 
ph420 = angle(oiGet(oi,'optics otf',420)); 

OTF550 = abs(oiGet(oi,'optics otf',550));
ph550 = angle(oiGet(oi,'optics otf',550)); 

OTF670 = abs(oiGet(oi,'optics otf',670));
ph670 = angle(oiGet(oi,'optics otf',670)); 

freq = oiGet(oi,'fsupportx','cyclesPerDegree');
nSamp = 40;

% Indicate spurious resolution by the sign of the phase
nexttile;
tmp = sign(ph420(1,1:nSamp)); tmp(1) = 1;
plot(freq(1:nSamp),OTF420(1,1:nSamp).*tmp,'b-'); hold on;
tmp = sign(ph550(1,1:nSamp)); tmp(1) = 1;
plot(freq(1:nSamp),OTF550(1,1:nSamp).*tmp,'g-'); hold on;
tmp = sign(ph670(1,1:nSamp)); tmp(1) = 1;
plot(freq(1:nSamp),OTF670(1,1:nSamp).*tmp,'r-')
grid on;
xlabel('Spatial freq (c/deg)');
ylabel('Amplitude');
title('Wavefront, Thibos');

%% END