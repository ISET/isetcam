%% Vignetting
%
% Illustrate the optical fall off with field height, modeled by cos4th.
%
%


%% Large field of view scene
scene = sceneCreate('uniform d65',512);
scene = sceneSet(scene,'fov',20);

% Diffraction limited shift-invariant optics
oi = oiCreate('shift invariant');
focalLength = oiGet(oi,'optics focallength');

height = oiGet(oi,'height','m');
X = linspace(-height,height,100);
theta = atand(X/focalLength);
falloff = cosd(theta).^4'
ieNewGraphWin; plot(X,falloff)

S = sqrt(focalLength^2 + X.^2);
ieNewGraphWin; plot(X,(X./S).^4)

oi = oiCompute(oi,scene);
sz = oiGet(oi,'size');

oiPlot(oi,'illuminance hline',[1,sz(2)/2]);
oiWindow(oi);
[uData,fig] = oiPlot(oi,'illuminance hline',[1,20]);
ax = gca;
ax.Children.Color = [0 0 0];


oi = oiSet(oi,'optics focallength', 4*focalLength);
oi = oiCompute(oi,scene);
oiPlot(oi,'illuminance hline',[1,sz(2)/2]);
oiWindow(oi);
[uData,fig] = oiPlot(oi,'illuminance hline',[1,20]);
ax = gca;
ax.Children.Color = [0 0 0];


%% END