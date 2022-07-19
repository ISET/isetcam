%% s_sensorComparison
%
% Run the same OI through multiple sensors, just for comparison.  BW
% used this script to create the sensor images for the Ford
% presentation.
%
% Combines two test charts:  Macbeth and a sweep frequency.
%
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

hfov = 20;
scene = sceneSet(scene,'fov',hfov);
vfov = sceneGet(scene,'v fov');
sceneWindow(scene);

%%
oi = oiCreate;
oi = oiSet(oi,'optics fnumber',1.2);
oi = oiCompute(oi,scene);
oiWindow(oi);

%% Now run through some sensors

% sensorList = {'bayer-rggb','imx363','rgbw','mt9v024','mt9v024','imec44','cyym','monochrome'};

% Used for Ford talk
sensorList = {'imx363','mt9v024','cyym'};
ip = ipCreate;

for ii=1:numel(sensorList)
    if isequal(sensorList{ii},'mt9v024') 
        sensor = sensorCreate(sensorList{ii},[],'rccc');
    else
        sensor = sensorCreate(sensorList{ii});
    end

    sensor = sensorSet(sensor,'pixel size',1.5e-6);
    sensor = sensorSet(sensor,'hfov',hfov,oi);
    sensor = sensorSet(sensor,'vfov',vfov);
    sensor = sensorCompute(sensor,oi);
    sensorWindow(sensor);

    sensor = sensorSet(sensor,'pixel size',4.5e-6);
    sensor = sensorSet(sensor,'hfov',hfov,oi);
    sensor = sensorSet(sensor,'vfov',vfov);
    sensor = sensorCompute(sensor,oi);

    [~,img] = sensorShowCFA(sensor,[],[3 3]);
    sensorWindow(sensor);
    %{
     ip = ipCompute(ip,sensor);
     ipWindow(ip);
    %}
end

%%



