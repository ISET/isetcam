clear; close all;

ieInit;
%% Create Sensor

sensor = sensorCreateIMECSSM4x4vis();

%% Create Scene 
fov = 40;      % what is this?
%scene  = sceneCreate('reflectance chart');
scene  = sceneCreate('macbeth d65');
scene  = sceneSet(scene,'fov',fov);
sceneWindow(scene);
oi = oiCreate;
oi = oiCompute(oi,scene);



%% Compute optical image
% sensor = sensorSet(sensor,'exposure time',100e-3);
sensor = sensorSet(sensor, 'auto exp', 1);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Get Digital numbers
DN = sensorGet(sensor,'digitalvalues');


figure(10);clf;
imagesc(DN,[0 2^10]); colormap gray
axis equal 

%% Demosaic
band=1; %band counter
for r=1:4
    for c=1:4
        D(:,:,band) = DN(r:4:end,c:4:end);
       band=band+1;
    end
end

    
%oiWindow(oi)
fig=figure(11);clf;
sliceViewer(D);
fig.Position=[200 201 594 499];
colormap gray

