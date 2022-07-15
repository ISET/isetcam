%% s_sensorComparison
%
% Run the same OI through multiple sensors, just for comparison
%
% Use a test chart
%

%%
ieInit

%%
patchSize = 64;
sceneC = sceneCreate('macbethD65',patchSize);
sceneWindow(sceneC);
sz = sceneGet(sceneC,'size');

sceneS = sceneCreate('zone plate',sz(1));
sceneWindow(sceneS);

scene = sceneCombine(sceneC,sceneS,'direction','horizontal');

fov = 5;
scene = sceneSet(scene,'fov',fov);
sceneWindow(scene);

%%
oi = oiCreate;
oi = oiSet(oi,'optics fnumber',1.2);
oi = oiCompute(oi,scene);
oiWindow(oi);

%% Now run through some sensors

sensorList = {'bayer-rggb','imx363','rgbw','mt9v024','imec44'};
ip = ipCreate;

for ii=1:numel(sensorList)
    sensor = sensorCreate(sensorList{ii});
    sensor = sensorSet(sensor,'fov',fov);
    sensor = sensorCompute(sensor,oi);
    sensorWindow(sensor);
    %{
     ip = ipCompute(ip,sensor);
     ipWindow(ip);
    %}
end

%%



