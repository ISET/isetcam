%% Multispectral camera with 9 filters (3 by 3)
clear;
ieInit



%% Create Multispectral Sensor

%%% Pixel
fillFactor = 0.42;
pSize = fillFactor*[5.5 5.5]*1e-6; % CMV2000 sensor
pixel=pixelCreate('default',400:700,pSize);

% Sensor create
filterFile = fullfile(isetRootPath,'data','sensor','imec','qe_IMEC.mat');
sensor = sensorCreate('custom',pixel,[1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16],filterFile);
sensor = sensorSet(sensor,'pixel size ',5.5*1e-6);
sensor = pixelCenterFillPD(sensor,fillFactor);
sensor = sensorSet(sensor,'rows',1016);
sensor = sensorSet(sensor,'cols',2040);
sensor = sensorSet(sensor,'name','multispectral');
sensor=sensorSet(sensor,'quantization','10 bit');
sensor = sensorSet(sensor, 'exp time', 0);


% Set Pixel properties
sensor = sensorSet(sensor,'pixel voltage swing',2.8);
sensor = sensorSet(sensor,'pixel dark voltage',1e-3);
sensor = sensorSet(sensor,'pixel conversion gain',110e-6);


% Noise properties
dsnuLevel = 0.05;       % Std. dev. of offset in volts
prnuLevel = 0.1;        % Std. dev of gain, around 1, as a percentage
sensor = sensorSet(sensor,'pixel read noise volts',1e-3);
sensor = sensorSet(sensor,'DSNU level',dsnuLevel);
sensor = sensorSet(sensor,'PRNU level',1);





%% Create Scene
fov = 60;% what is this?
%scene  = sceneCreate('reflectance chart');
scene  = sceneCreate('macbeth d65');
scene  = sceneSet(scene,'fov',fov);



%% Create Camera
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensor);
%camera=cameraSet(camera,'focallength',8*1e-3)


% Q: how to choose focal length
% Q: What parameters should i Set at this moment?


%% Compute optical image
camera = cameraCompute(camera,scene); % what does this do?
oi = camera.oi;

% Full image
sensor = sensorCompute(sensor, oi);
DN = sensorGet(sensor,'digitalvalues');


figure(10);clf;
imagesc(DN,[0 2^10]);
colormap(gray(64));
axis equal

%% Demosaic
band=1; % band counter
D = zeros(254,510,16);
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
colormap(gray(64))





