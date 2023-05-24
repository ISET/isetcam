%% Wavefront calculations with the Zernike polynomials
%
% ISET includes two ways to calculate defocus, one based on
% Hopkins and diffraction calculations that was implemented based
% on the
% <http://white.stanford.edu/~brian/papers/color/MarimontWandell1994.pdf Marimont and Wandell (1994, JOSA) paper>.
%
% More recently, we introduced a method based on wavefront
% aberrations described in terms of
% <https://en.wikipedia.org/wiki/Zernike_polynomials Zernike polynomials>.
% Some applications of the Zernike polynomial method are explained here.
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% The wavefront methods relies on the wavefront structure

wave = 400:20:700;

% The default parameters are set here, for a diffraction limited lens.
wvf = wvfCreate('wave',wave);

% Before plotting, we need to calculate the PSF
wvf = wvfComputePSF(wvf);

thisWave = 540;   % nanometers
pRange = 10;      % microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange);

%% Here are the Zernike polynomial coefficient names

doc('wvfOSAIndexToName');

%% We can adjust these and plot the new point spread function

% Here is some defocus
wvf = wvfSet(wvf,'zcoeffs',2,'defocus');
wvf = wvfComputePSF(wvf);

thisWave = 540;   % nanometers
pRange = 10;      % microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange);

% Now we add some oblique_astigmatism
wvf = wvfSet(wvf,'zcoeffs',2,'oblique_astigmatism');
wvf = wvfComputePSF(wvf);

thisWave = 550;   % nanometers
pRange = 10;      % microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange);

%% These PSFs are wavelength dependent

thisWave = 420;   % nanometers
pRange = 10;      % microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange);

thisWave = 700;   % nanometers
pRange = 10;      % microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange);

%% Convert the wavefront structure to an oi

oi = wvf2oi(wvf);

oiData = oiPlot(oi,'psf','um',420);

% Zoom in using the returned oiData
pRange = 10;
c = logical(-pRange < oiData.x(1,:)) & logical(oiData.x(1,:) < pRange);
r = logical(-pRange < oiData.y(:,2)) & logical(oiData.y(:,2) < pRange);
vcNewGraphWin;
mesh(oiData.x(r,c),oiData.y(r,c),abs(oiData.psf(r,c)))

%% Plot the psf at 700 nm
oiData = oiPlot(oi,'psf','um',700);

% Zoom in using the returned oiData
pRange = 10;
c = logical(-pRange < oiData.x(1,:)) & logical(oiData.x(1,:) < pRange);
r = logical(-pRange < oiData.y(:,2)) & logical(oiData.y(:,2) < pRange);
vcNewGraphWin;
mesh(oiData.x(r,c),oiData.y(r,c),abs(oiData.psf(r,c)))

%%

