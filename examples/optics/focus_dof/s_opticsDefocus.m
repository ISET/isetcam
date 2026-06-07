%% t_opticsDefocus
%
% Illustrate

scene = sceneCreate('disk array',256,32,[2,2]);
scene = sceneSet(scene,'fov',0.5);
 
%% Specify a wvf and create
 
wvf = wvfCreate('wave',sceneGet(scene,'wave'));
oi = oiCreate('wvf',wvf);
oi = oiCompute(oi,scene);
oiWindow(oi);
 
%% Blur
oi = oiSet(oi,'wvf zcoeffs',2.5,'defocus');
oi = oiCompute(oi,scene);
oiWindow(oi);
 
initialPhotons = mean(oiGet(oi,'photons'),'all');
 
%% Vertical astigmatism
oi = oiSet(oi,'wvf zcoeffs',1,'vertical_astigmatism');
oi = oiCompute(oi,scene);
oiWindow(oi);
 
%% Vertical astigmatism
oi = oiSet(oi,'wvf zcoeffs',0,'vertical_astigmatism');
oi = oiCompute(oi,scene);
oiWindow(oi);
 
%% Blur
oi = oiSet(oi,'wvf zcoeffs',0,'defocus');
oi = oiCompute(oi,scene);
oiWindow(oi);
endingPhotons = mean(oiGet(oi,'photons'),'all');
 
% Check
assert(abs((initialPhotons/endingPhotons) - 1) < 1e-6);
 
%% Now change the pupil diameter
 
% Still diffraction limited, but sharper because a larger pupil diameter
wvf = oiGet(oi,'wvf'); 
pDiameter = wvfGet(wvf,'calc pupil diameter');
wvf = wvfSet(wvf,'calc pupil diameter',2*pDiameter);
oi = oiSet(oi,'optics wvf',wvf);

oi = oiCompute(oi,scene);
oiWindow(oi);
 
%% Put the pupil diameter back
wvf = wvfSet(wvf,'calc pupil diameter',pDiameter);
oi = oiSet(oi,'optics wvf',wvf);
oi = oiCompute(oi,scene);
endingPhotons = mean(oiGet(oi,'photons'),'all');
 
oiWindow(oi);
 
assert(abs((initialPhotons/endingPhotons) - 1) < 1e-6);

%%