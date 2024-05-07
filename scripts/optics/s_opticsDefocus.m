%% Calculating a defocused image
%
% ISET includes two ways to calculate defocus.  One method implements the
% classic work of Hopkins using *humanCore* and *opticsDefocusCore*. That
% method, illustrated here, calculates the Optical transfer functon (OTF)
% and linespreads for defocus under different conditions.
%
% ISET also can calculate defocus using wavefront aberrations based on
% Zernike polynomials.  These are implemented in the opticalimage/wavefront
% directory. Tutorials emphasizing the wavefront methods are described in
% *t_wvf<TAB>* tutorials.
%
% See also:  sceneCreate, opticsDefocusCore, humanWaveDefocus,
%            t_opticsWVF, t_opticsWVFZernike
%
% Copyright ImagEval Consultants, LLC, 2011

%%
ieInit

%% Test scene
s = sceneCreate('radial lines');
oi = oiCreate;
optics = oiGet(oi,'optics');
wave = opticsGet(optics,'wave');

sampleSF = 0:60;                   % Spatial frequency
D = zeros(size(wave));             % No defocus (diffraction limited)
otf = opticsDefocusCore(optics,sampleSF,D);

%%
ieNewGraphWin;
mesh(sampleSF,wave,otf)
set(gca,'zlim',[0 1]);
xlabel('Spatial Frequency (cyc/deg)'), ylabel('wave'), zlabel('OTF')
az = 40.; el = 20; view(az,el);

%% Example: Human lens fnumber without chromatic aberration or williams factor

sampleSF = 0:60;  % Spatial frequency
optics = opticsCreate('wvf human');   % Changed July 25, 2023
optics = initDefaultSpectrum(optics);
wave = opticsGet(optics,'wave');

% No defocus per wavelength, so not really human yet.
D = zeros(size(wave));             % No wavelength dependent defocus
otf = opticsDefocusCore(optics,sampleSF,D);

vcNewGraphWin;
mesh(sampleSF,wave,otf)
set(gca,'zlim',[0 1]);
xlabel('Spatial Frequency (cyc/deg)'), ylabel('wave'), zlabel('OTF')
az = 40.; el = 20; view(az,el);

%% Set human wavelength dependent defocus

wave = opticsGet(optics,'wave');
D = humanWaveDefocus(wave);
otf = opticsDefocusCore(optics,sampleSF,D);

vcNewGraphWin;
mesh(sampleSF,wave,otf)
set(gca,'zlim',[0 1]);
xlabel('Spatial Frequency (cyc/deg)'), ylabel('wave'), zlabel('OTF')
az = 40.; el = 20; view(az,el);

%%