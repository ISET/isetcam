%%
% ISET can build shift invariant representations based on
% wavefront aberrations specified by Zernike polynomials. This
% allows us to create shift invariant representations that are
% diffraction limited (no aberrations) or with various simple
% aberrations (astigmatism, coma, defocus).
%
% The code in ISET is a simplified form of the wavefront tool in
% ISETBIO, which always includes the human longitudinal chromatic
% aberration and the Stiles-Crawford effect.  That tool is
% designed to apply to human calculations of the wavefront
% optics.
%
% This validation script test the wavefront calculation and the
% diffraction limited calculation.  The dlMTF code has been
% tested, and we show that the wavefront version matches the
% results.
%
% Then we show how to adjust the Zernike polynomial coefficients
% to produce different defocus and other wavefront aberrations.
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% I compared this with the ISETBIO verion of wvfP
% they are identical at 550, when there is no chromatic
% abberation

% Create the wvf parameter structure with the appropriate values
thisWave = 550;
pupilMM = 3; % Could be 6, 4.5, or 3
fLengthM = 17e-3;

wvfP = wvfCreate('wave', thisWave, 'name', sprintf('%d-pupil', pupilMM));
wvfP = wvfSet(wvfP, 'pupil diameter', pupilMM);
wvfP = wvfComputePSF(wvfP);
wvfP = wvfSet(wvfP, 'focal length', fLengthM); % 17 mm focal length for deg per mm

pRange = 15; % Microns
wvfPlot(wvfP, '2d psf space', 'um', thisWave, pRange);
title(sprintf('Calculated pupil diameter %.1f mm', pupilMM));

% This is the radius of the Airy disk for this fnumber
fNumber = wvfGet(wvfP, 'focal length', 'mm') / pupilMM;
radius = (2.44 * fNumber * thisWave * 10^-9) / 2 * ieUnitScaleFactor('um');
nSamp = 200;
[adX, adY, adZ] = ieShape('circle', nSamp, radius);
adZ = adZ + max(wvfP.psf{1}(:)) * 5e-3;
hold on; p = plot3(adX,adY,adZ,'k-'); set(p,'linewidth',3); hold off;
title(sprintf('WVF psf at %d', thisWave))

%% Now, let's compare the psf for the diffraction limited ISET optics

oi = oiCreate('diffraction limited');
oi = oiSet(oi, 'optics focal length', fLengthM);
oi = oiSet(oi, 'optics fnumber', fLengthM*1e+3/pupilMM); % I think 19 mm in ISET

% Check values
% oiGet(oi,'optics focal length','mm')
% oiGet(oi,'optics aperture diameter','mm')
uData = oiPlot(oi, 'psf', [], thisWave);
x = getMiddleMatrix(uData.x, 50);
y = getMiddleMatrix(uData.y, 50);
psf = getMiddleMatrix(uData.psf, 50);
vcNewGraphWin; mesh(x, y, psf)

fNumber = oiGet(oi, 'optics fnumber');
radius = (2.44 * fNumber * thisWave * 10^-9) / 2 * ieUnitScaleFactor('um');
nSamp = 200;
[adX, adY, adZ] = ieShape('circle', nSamp, radius);
adZ = adZ + max(psf(:)) * 5e-3;
hold on; p = plot3(adX,adY,adZ,'k-'); set(p,'linewidth',3); hold off;
title(sprintf('WVF psf at %d', thisWave))

% Get the otf data this way
oiData = oiPlot(oi, 'otf', [], thisWave);
maxF = 2000;
wvData = wvfPlot(wvfP, 'otf', 'mm', thisWave, maxF);

%% Compare ISET and WVF to see how close the OTFs are after interpolation

% Remember that the DC position must account for whether the
% length of fx is even or odd
vcNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else, wvMid = length(wvData.fx) / 2 + 1;
end
plot(wvData.fx, wvData.otf(:, wvMid), 'r-');
hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else, oiMid = length(oiData.fx) / 2 + 1;
end
plot(oiData.fx, oiData.otf(:, oiMid), 'b-')
legend({'wvf', 'oi'})

%% Now, we make a multispectral wvf and convert the WVF to ISET

% Create the wvf parameter structure with the appropriate values
wave = (400:50:700);
pupilMM = 3; % Could be 6, 4.5, or 3
fLengthM = 17e-3;

wvfP = wvfCreate('wave', wave, 'name', sprintf('%d-pupil', pupilMM));
wvfP = wvfSet(wvfP, 'pupil diameter', pupilMM);
wvfP = wvfComputePSF(wvfP);
wvfP = wvfSet(wvfP, 'focal length', fLengthM); % 17 mm focal length for deg per mm

pRange = 15; % Microns
thisWave = 550;
wvfPlot(wvfP, '2d psf space', 'um', thisWave, pRange);
title(sprintf('Calculated pupil diameter %.1f mm', pupilMM));

%%
oi = wvf2oi(wvfP);

%% Compare the OTF plots from the two worlds

thisWave = 550;
oiData = oiPlot(oi, 'otf', [], thisWave);
wvData = wvfPlot(wvfP, '2D otf', 'mm', thisWave);

vcNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else, wvMid = length(wvData.fx) / 2 + 1;
end
plot(wvData.fx, wvData.otf(:, wvMid), 'r-');
hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else, oiMid = length(oiData.fx) / 2 + 1;
end
plot(oiData.fx, oiData.otf(:, oiMid), 'b-')
legend({'wvf', 'oi'})

%% Show the psfs
oiPlot(oi, 'psf550');

% This is the psf and the radius of the Airy disk for this fnumber
thisWave = 550;
wvfPlot(wvfP, '2d psf space', 'um', thisWave, 10);
fNumber = oiGet(oi, 'optics fNumber');
radius = ((2.44 * fNumber * thisWave * 10^-9) / 2) * ieUnitScaleFactor('um');
nSamp = 200;
[adX, adY, adZ] = ieShape('circle', nSamp, radius);
adZ = adZ + max(wvfP.psf{1}(:)) * 1e-2;
hold on; p = plot3(adX,adY,adZ,'k-'); set(p,'linewidth',3); hold off;

%% If the OTF data are basically matched, we should be able to interpolate

% That is, we should be able to take the wvf otf data and
% interpolate them onto the oi otf frequency values.

% There are very small differences (~0.005) at a few interpolated values
est = interp2(wvData.fx, wvData.fy, wvData.otf, oiData.fx, oiData.fy, 'cubic', 0);
vcNewGraphWin; plot(est(:), oiData.otf(:), 'rx')
axis equal
identityLine

% Nearly perfect.
% vcNewGraphWin; histogram(est(:) - oiData.otf(:),100)

%% Test scene

s = sceneCreate('radial lines');
s = sceneSet(s, 'hfov', 2);
ieAddObject(s);

%% Calculate

oi = oiCompute(oi, s);
oi = oiSet(oi, 'name', sprintf('oi f/# %.2f', oiGet(oi, 'fnumber')));
ieAddObject(oi);
oiWindow;

%% Standard way of creating a diffraction limited optics
oiD = oiCreate;
oiD = oiSet(oiD, 'optics fnumber', wvfGet(wvfP, 'fnumber'));
oiD = oiCompute(oiD, s);
oiD = oiSet(oiD, 'name', sprintf('wvf f/# %.2f', wvfGet(wvfP, 'fnumber')));
ieAddObject(oiD);
oiWindow;

%% Finally, show off with setting a defocus on the wvf structure

def = 1;
wvfD = wvfSet(wvfP, 'zcoeff', def, 'defocus');
wvfD = wvfSet(wvfD, 'z pupil diameter', 8);
wvfD = wvfComputePSF(wvfD);
wvfPlot(wvfD, '2d psf space', 'um', thisWave, pRange);
title(sprintf('Z defocus parameter %.1f', def));

oiDD = wvf2oi(wvfD);
oiDD = oiCompute(oiDD, s);
oiDD = oiSet(oiDD, 'name', sprintf('Z defocus %.1f', def));
ieAddObject(oiDD);
oiWindow;

%%
