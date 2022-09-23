%% Illustrate displayReflectance creation
%
% DEBUG:  The scale factor on the illuminant is not quite right
% the reflectances 

%% Make an sRGB image

setTemp = 7000;
scene = sceneCreate('macbeth d65');
wave = sceneGet(scene,'wave');

scene = sceneAdjustIlluminant(scene,blackbody(wave,setTemp,'energy'),true);

oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate; 
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
ip = ipCreate;
ip = ipCompute(ip,sensor);

rgb = ipGet(ip,'srgb');

%% Analyze the sRGB for color temp

estTemp = srgb2colortemp(rgb);
[d,spd,illE] = displayReflectance(estTemp);

%% Read the sRGB data using the display

newScene = sceneFromFile(rgb,'rgb',100,d);
% sceneWindow(newScene);

%% Adjust the illuminant, correcting for reflectance

newScene = sceneSet(newScene,'illuminant energy',illE);
r = sceneGet(newScene,'reflectance');
newScene = sceneSet(newScene,'illuminant energy',illE*max(r(:)));
sceneWindow(newScene);

%% END
