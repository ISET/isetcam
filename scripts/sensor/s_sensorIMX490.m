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

%% Make a combined iimage

% MCC side
patchSize = 96;
sceneC = sceneCreate('macbethD65',patchSize);
sz = sceneGet(sceneC,'size');
sceneC = sceneSet(sceneC,'resize',round([sz(1), sz(2)/2]));
sceneWindow(sceneC);

% Sweep frequency side
sceneS = sceneCreate('sweep frequency',sz(1),sz(1)/16);
sceneWindow(sceneS);

% Combine
scene = sceneCombine(sceneC,sceneS,'direction','horizontal');

hfov = 20;
scene = sceneSet(scene,'fov',hfov);
vfov  = sceneGet(scene,'v fov');
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
%sensorList = {'imx363'};


for ii=1:numel(sensorList)
    if isequal(sensorList{ii},'mt9v024') 
        sensor = sensorCreate(sensorList{ii},[],'rccc');
    else
        sensor = sensorCreate(sensorList{ii});
    end

    sensor = sensorSet(sensor,'pixel size',1.5e-6);
    sensor = sensorSet(sensor,'hfov',hfov,oi);
    sensor = sensorSet(sensor,'vfov',vfov);
    sensor = sensorSet(sensor,'auto exposure',true);
    sensor = sensorCompute(sensor,oi);
    sensorWindow(sensor);

    switch sensorList{ii}
        case 'imx363'
            ip = ipCreate('imx363 RGB',sensor);
            ip = ipCompute(ip,sensor);
            ipWindow(ip);
        case 'mt9v024'
            ip = ipCreate('mt9v024 RCCC', sensor);
            % NOTE: ipCreate doesn't seem to take its cue from the 
            %       sensor that it is rccc, so we do it manually
            ip = ipSet(ip,'demosaic method','analog rccc');
            ip = ipCompute(ip,sensor);
            ipWindow(ip);
    end

    sensor = sensorSet(sensor,'pixel size constant fill factor',6e-6);
    sensor = sensorSet(sensor,'hfov',hfov,oi);
    sensor = sensorSet(sensor,'vfov',vfov);
    sensor = sensorSet(sensor,'auto exposure',true);
    sensor = sensorCompute(sensor,oi);

    switch sensorList{ii}
        case 'imx363'
            ip = ipCreate('imx363 RGB',sensor);
            ip = ipCompute(ip,sensor);
            ipWindow(ip);
        case 'mt9v024'
            ip = ipCreate('mt9v024 RCCC', sensor);
            % NOTE: ipCreate doesn't seem to take its cue from the 
            %       sensor that it is rccc, so we do it manually
            ip = ipSet(ip,'demosaic method','analog rccc');
            ip = ipCompute(ip,sensor);
            ipWindow(ip);
    end
    
    % [~,img] = sensorShowCFA(sensor,[],[3 3]);
    sensorWindow(sensor);

end

%%



