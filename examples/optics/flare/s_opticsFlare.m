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

%% Create optics with a polygon aperture, and some lines and scratches

wvf = wvfCreate;  
pupilMM = 3; flengthM = 7e-3;
wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf = wvfSet(wvf,'focal length',flengthM);

% Create a triangular aperture, dust and scratches. There are many
% parameters for this function, including dot mean, line mean, dot sd, line
% sd, line opacity.  They are returned in params
nsides = 3;
[aperture,params] = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);

wvf = wvfCompute(wvf,'aperture',aperture);

%% Summarize
disp(params);

ieNewGraphWin([], 'wide');
tiledlayout(1,3);
nexttile; wvfPlot(wvf,'image pupil amp','unit','um','wave',550,'window',false);
nexttile; wvfPlot(wvf,'image pupil phase','unit','um','wave',550,'window',false);
nexttile; uData = wvfPlot(wvf,'psf','unit','um','wave',550,'plot range',20);

%% Illustrate with a point array

scenePoint = sceneCreate('point array',384,128);
scenePoint = sceneSet(scenePoint,'fov',1);

oi = oiCompute(wvf,scenePoint);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi); 
oiSet(oi,'gamma',0.5); drawnow;

%% Show the oi PSF

% It comes through properly so the graph corresponds to the wvfPlot()
% above.
oiPlot(oi,'psf550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%% HDR Test scene. Green repeating circles

sceneHDR = sceneCreate('hdr');
sceneHDR = sceneSet(sceneHDR,'fov',1);
% sceneWindow(sceneHDR);

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
wvfPlot(wvf,'psf','unit','um','wave',550,'plot range',20,'airy disk',true);


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
wvfPlot(wvf,'psf','unit','um','wave',550,'plot range',20,'airy disk',true);

oi = oiCompute(wvf,sceneHDR);
oi = oiSet(oi,'name','wvf defocus');
oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%% END