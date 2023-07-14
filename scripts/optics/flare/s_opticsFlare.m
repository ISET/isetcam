%%  Experiments with flare
% 
% This is a longer version of v_opticsFlare, with more experiments and
% tests. 
%
% One of the things to notice is that the long flare lines add
% constructively in some cases, depending on the shape of the very
% bright light source.  So the flare pattern we expect depends on the
% shape of the light.
%
% See also
%   v_opticsFlare, s_wvfOI, s_wvfChromatic, s_wvfDiffraction 

%%
ieInit;

%% Create some optics with a little defocus and astigmatism

wvf = wvfCreate;  
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

%{
ieNewGraphWin([], 'wide');
subplot(1,2,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,2,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
%}

%% Illustrate with a point array

scenePoint = sceneCreate('point array',384,128);
scenePoint = sceneSet(scenePoint,'fov',1);

oi = oiCompute(wvf,scenePoint);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi); 
oiSet(oi,'gamma',0.5); drawnow;

%% Show the oi PSF

oiPlot(oi,'psf550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%% HDR Test scene. Green repeating circles

sceneHDR = sceneCreate('hdr');
sceneHDR = sceneSet(sceneHDR,'fov',3);
% sceneWindow(sceneHDR);

%% These two scenes are both 384x384.

[oiHDR, pupilFunctionHDR, psfHDR, psfSupportHDR] = piFlareApply(sceneHDR,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));

[oiPoint, pupilFunctionPoint, psfPoint,psfSupportPoint] = piFlareApply(scenePoint,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oiWindow(oiPoint);

% The PSFs when plotted as values against one another are the same (3rd panel).
% But when plotted with respect to real spatial units, they differ.  I
% don't know why (yet).  Though possibly because the FOV of the
% sceneHDR is 3 deg and scenePoint is 1 deg
ieNewGraphWin([],'wide'); tiledlayout(1,3);
psfP = psfPoint(:,:,16); psfH = psfHDR(:,:,16);  % 16 is 550 nm
nexttile; mesh(psfSupportPoint(:,:,1),psfSupportPoint(:,:,2),psfP); title('Point');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
nexttile; mesh(psfSupportHDR(:,:,1),psfSupportHDR(:,:,2),psfH); title('HDR');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
nexttile; plot(psfP(:),psfH(:),'o'); identityLine;                                     

%%  Another issue: 
% 
% We change the spatial samples in the point scene, and the size of
% the PSF changes. This also suggests we aren't controlling the
% spatial dimensions correctly in piFlareApply

scenePoint2 = sceneCreate('point array',512,128);
scenePoint2 = sceneSet(scenePoint2,'fov',1);

[oiPoint2, pupilFunctionPoint2, psfPoint2, psfSupportPoint2] = piFlareApply(scenePoint2,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oiWindow(oiPoint2);

% The PSFs are still identical - 16 is a wavelength of 550
ieNewGraphWin([],'wide'); tiledlayout(1,2);
psfP2 = psfPoint2(:,:,16);
nexttile; mesh(psfSupportPoint2(:,:,1),psfSupportPoint2(:,:,2),psfP2); title('Point2');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
nexttile; mesh(psfSupportPoint(:,:,1),psfSupportPoint(:,:,2),psfH); title('Point');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
size(psfP2)
size(psfH)
% The PSFs have dimensions.  So we can't make this plot
% nexttile; plot(psfP2(:),psfH(:),'o'); identityLine;     

%% Notice that the PSF of the oi does not match the returned psf 

% No signs of the flare.
oiPlot(oiPoint2,'psf',550);


%% Experiment with the fov 

% When I made the FOV of scenePoint match the FOV of sceneHDR, the
% PSFs match, too.  So that is the key thing to figure out in
% piFlareApply. 
scenePoint3 = sceneSet(scenePoint,'fov',3);
[oiPoint3, pupilFunctionPoint3, psfPoint3,psfSupportPoint3] = piFlareApply(scenePoint3,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oiWindow(oiPoint3);

ieNewGraphWin([],'wide'); tiledlayout(1,3);
psfP3 = psfPoint3(:,:,16); 
nexttile; mesh(psfSupportPoint3(:,:,1),psfSupportPoint3(:,:,2),psfP3); title('Point');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
nexttile; mesh(psfSupportHDR(:,:,1),psfSupportHDR(:,:,2),psfH); title('HDR');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);
nexttile; plot(psfP(:),psfH(:),'o'); identityLine;   


%%

oi = oiCompute(wvf,sceneHDR);
oi = oiSet(oi,'name','wvf');
oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%% Change the number of sides
scenePoint = sceneSet(scenePoint,'fov',1);

nsides = 5;
aperture = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);

% Pupil and PSF
wvf = wvfCompute(wvf,'aperture',aperture);
wvfPlot(wvf,'psf','um',550,20,'airy disk');


%%
oi = oiCompute(wvf,scenePoint);
oi = oiSet(oi,'name',sprintf('wvf-test %d-sides',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi); 
oiSet(oi,'render flag','hdr'); drawnow;

%% Now the HDR scene

oi = oiCompute(wvf,sceneHDR);
oi = oiCrop(oi,'border');
oi = oiSet(oi,'name',sprintf('wvf %d-sides',nsides));

oiWindow(oi); 
oiSet(oi,'render flag','hdr'); drawnow;

%% Add some blur

wvf = wvfSet(wvf,'zcoeffs',1,{'defocus'});

% Now create some flare based on the aperture, dust and scratches.
% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[aperture, params] = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);

wvf = wvfPupilFunction(wvf,'aperture function',aperture);
wvf = wvfComputePSF(wvf,'compute pupil func',false);  % force as false is important
wvfPlot(wvf,'psf','um',550,20,'airy disk');

oi = oiCompute(wvf,sceneHDR);
oi = oiSet(oi,'name','wvf defocus');
oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%% END