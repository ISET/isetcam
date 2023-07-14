%% Flare simulation using the wvf method
% 
% The flare simulation operates by creating pupil amplitude functions that
% have non-circular shapes (polygons) and contain scratches and dust in the
% aperture itself.
%
% See also 
%   v_opticsVWF

%%
ieInit;

%% A simple test scene

scene = sceneCreate('point array',128,32);
scene = sceneSet(scene,'fov',1);

%% Experiment with different wavefronts

wvf = wvfCreate;    % Default wavefront 5.67 fnumber
pupilMM = 3; flengthM = 7e-3;
wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf = wvfSet(wvf,'focal length',flengthM);

% Now create some flare based on the aperture, dust and scratches.
% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
aperture = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);
% ieNewGraphWin; imagesc(aperture); axis image;

% This does not yet work.
wvf = wvfCompute(wvf,'aperture',aperture);

wvfPlot(wvf,'psf','um',550,20,'airy disk');

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');

%% Convert to an OI

oi = wvf2oi(wvf);
[uData, fig] = oiPlot(oi,'psf 550');

psfPlotrange(fig,oi);
thisWave = wvfGet(wvf,'wave');
AD = airyDisk(thisWave,wvfGet(wvf,'fnumber'),'diameter',true);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

%% oiCompute using the wvf

oi = oiCompute(wvf,scene);

% Show the oi PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

%% Make an image

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi);
oiSet(oi,'gamma',0.5); drawnow;

%% HDR test scene

scene = sceneCreate('hdr');
scene = sceneSet(scene,'fov',1);

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','wvf');
oi = oiCrop(oi,'border');
oiWindow(oi);
oiSet(oi,'gamma',0.5); drawnow;

%% The same scene through Zhenyi's piFlareApply

% Close match.
[oiApply, pMask, psf] = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));

oiApply = oiSet(oiApply,'name','piFlare');
oiWindow(oiApply);
oiSet(oiApply,'gamma',0.5); drawnow;

%% END
