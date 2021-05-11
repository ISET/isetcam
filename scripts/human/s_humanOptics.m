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
% See also: plotOI, s_HumanLSF
%
% Copyright ImagEval Consultants, LLC, 2011.

%% OTF
wave = 400:10:700; % nanometer
sampleSF = 0:0.5:50; % cyc/deg
p = 0.0015; % Pupil radius (m)
D0 = 60; % Dioptric power of human lens

otf = humanCore(wave, sampleSF, p, D0);

%% Plot the amplitude of the optical transfer function.
vcNewGraphWin;

mesh(sampleSF, wave, otf)
view(32.5, 14);
xlabel('Spatial freq cy/deg');
ylabel('Wavelength (nm)');
zlabel('OTF')

%% Plot graphs of a few sample wavelengths
% The effect of chromatic aberration (defocus in the short) is quite
% apparent in these graphs.

vcNewGraphWin;
waveList = [420, 550, 670];
cList = {'b-', 'g-', 'r-'};
for ii = 1:length(waveList)
    plot(sampleSF, otf(ieFindWaveIndex(wave, waveList(ii)), :), cList{ii});
    hold on
end
grid on

xlabel('Spatial freq cy/deg');
ylabel('OTF value');
legend({'420 nm', '550 nm', '670 nm'})
