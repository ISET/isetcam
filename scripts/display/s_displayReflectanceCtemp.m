%% Illustrate displayReflectance creation
%
% DEBUG:  The scale factor on the illuminant is not quite right
% the reflectances 
scene = sceneCreate('macbeth tungsten');
oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate; 
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
ip = ipCreate;
ip = ipCompute(ip,sensor);

rgb = ipGet(ip,'srgb');

ctemp = srgb2colortemp(rgb);
[d,spd,illE] = displayReflectance(ctemp);

% Figure out how to scale the illuminant, and then put that into
% displayReflectance.
%
%  newScene = sceneFromFile(rgb,'rgb',100,d);
%  newScene = sceneSet(newScene,'illuminant energy',illE);

newScene = sceneFromFile(rgb,'rgb',100);

sceneWindow(newScene);