%% Vignetting
%
% Illustrate the optical fall off with field height, modeled by cos4th.
%
%


%% Large field of view scene
scene = sceneCreate('uniform d65',512);
scene = sceneSet(scene,'fov',80);

% Diffraction limited shift-invariant optics
oi = oiCreate('shift invariant');
focalLength = oiGet(oi,'optics focallength');

oi = oiCompute(oi,scene);
sz = oiGet(oi,'size');

oiPlot(oi,'illuminance hline',[1,sz(2)/2]);
oiWindow(oi);


oi = oiSet(oi,'optics focallength', 4*focalLength);
oi = oiCompute(oi,scene);
oiPlot(oi,'illuminance hline',[1,sz(2)/2]);
oiWindow(oi);
[uData,fig] = oiPlot(oi,'illuminance hline',[1,20]);
ax = gca;
ax.Children.Color = [0 0 0];


%% END