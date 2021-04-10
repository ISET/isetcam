%%
% Example of rendering a cornell box specified with: (1) Setting the
% rendering parameters, (2) positioning the camera, (3) adding a lens, (4)
% write the recipe, (5)render irradiance and (6) compute the sensor image.

%% Initialize ISET and Docker
% Setup ISETcam and ISET3d system.
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
% The recipe includes all information of PBRT to do the rendering

%thisR = piRecipeDefault('scene name', 'macbethcheckerbox')
thisR = cbBoxCreate;
%% Add MCC color checker

assetTreeName = 'mccCB';

[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);

thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);

T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003*2 0]);

% Add extra light
lightName = 'new spot light';
newLight = piLightCreate(lightName,...
                        'type','distant',...
                        'spd','equalEnergy',...
                        'specscale', 1, ...
                        'cameracoordinate', true);
thisR.set('light', 'add', newLight);
thisR.get('light print');



 
%% Modify new rendering settings
 %thisR.set('film resolution',[320 320]);
 thisR.set('film resolution',2*[320 320]);
 nRaysPerPixel = 32;
 thisR.set('rays per pixel',nRaysPerPixel);
 thisR.set('nbounces',5); 

%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 25 cm from the front edge. The position of the 
% camera should be set to 25 + 15 = 40 cm from the origin
from = thisR.get('from');
newFrom = [0 0.125 -0.40]; % This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Build a lens
% List existing lens models
lensList;

lensfile = 'wide.77deg.4.38mm.json';

lensfile = 'wide.56deg.3.0mm.json'
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('focus distance', 0.5);
thisR.set('film diagonal', 7.04); % mm

%% Write and render
piWrite(thisR);
% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = 'CBLens';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);





%% Pixel
pSize = [5.5 5.5]*1e-6; % CMV2000 sensor
fillFactor = 0.42;
pixel=pixelCreate('default',400:700,pSize);


%% Create Multispectral Sensor
filterFile='multispectral.mat'
sensor = sensorCreate('custom',pixel,[1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16],filterFile);
sensor = sensorSet(sensor,'rows',4*round(1000/4));
sensor = sensorSet(sensor,'cols',4*round(1000/4));
sensor = sensorSet(sensor,'name','multispectral');
sensor=sensorSet(sensor,'quantization','10 bit')
sensor = sensorSet(sensor, 'exp time', 5e-3);



%% Create Camera
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensor);


%% Compute optical image

% Full image
sensor = sensorCompute(sensor, oi);
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

    
oiWindow(oi)
fig=figure(11);clf;
sliceViewer(D.^0.5);
fig.Position=[200 201 594 499];
colormap gray
