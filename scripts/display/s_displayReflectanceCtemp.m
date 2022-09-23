%% Illustrate displayReflectance creation
%
% DEBUG:  The scale factor on the illuminant is not quite right
% the reflectances 

%% Make an sRGB image

scene = sceneCreate('macbeth d65');
wave = sceneGet(scene,'wave');
scene = sceneAdjustIlluminant(scene,blackbody(wave,7000,'energy'),true);

oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate; 
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
ip = ipCreate;
ip = ipCompute(ip,sensor);

rgb = ipGet(ip,'srgb');

%% Analyze the sRGB image with the new tools

ctemp = srgb2colortemp(rgb);
[d,spd,illE] = displayReflectance(ctemp);

% Figure out how to scale the illuminant, and then put that into
% displayReflectance.
%
newScene = sceneFromFile(rgb,'rgb',100,d);
% sceneWindow(newScene);

newScene = sceneSet(newScene,'illuminant energy',illE);
% sceneWindow(newScene);

r = sceneGet(newScene,'reflectance');
max(r(:))
newScene = sceneSet(newScene,'illuminant energy',illE*max(r(:)));
sceneWindow(newScene);



% newScene = sceneFromFile(rgb,'rgb',100);
