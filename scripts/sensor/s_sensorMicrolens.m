%% Calculations for a microlens array on the sensor
%
% We analyze how to position microlenses with respect to the center of each
% pixel in order to optimize light gathering.  If we create a microlens
% array for a particular optics (imaging lens also called the taking lens)
% and sensor, then we are analyzing where we should place each microlens.
%
% This calculation is performed for a particular choice of the optics and a
% particular choice of the microlens.  The optics parameters are set in the
% optical image (optics slot).  The microlens parameters are set in the
% microlens structure.
%
% See also:  mlensCreate, mlAnalyzeArrayEtendue, plotSensorEtendue,
% mlensGet
%
% Copyright Imageval LLC, 2015

%%
ieInit

%% Create an oi with the default optics
scene = sceneCreate; ieAddObject(scene);

oi = oiCreate; ieAddObject(oi);

% Create a sensor with default properties.
sensor = sensorCreate;
mlens = mlensCreate(sensor,oi);
sensor = sensorSet(sensor,'microlens',mlens);

% Then give the sensor a decent field of view
fov = 20;
sensor = sensorSetSizeToFOV(sensor,fov,oi);
ieAddObject(sensor);

% Here are the default specifications for the optics and sensor
% iePTable(oi);
% iePTable(sensor);

%% Analyze the light loss if we do not have a microlens

sensor = mlAnalyzeArrayEtendue(sensor,'no microlens');
plotSensorEtendue(sensor);
title('No microlens')

% If we make the stack height close to 0, the peak here should be close to
% 1 and everything should flatten a bit.


%% Now what if each microlens is centered on the pixel

% This looks OK qualitatively.  The center gets boosted by the microlens
% because we are defeating pixel vignetting.
sensor = mlAnalyzeArrayEtendue(sensor,'centered');
plotSensorEtendue(sensor)
title('Microlens centered on each pixel')

%% If we have a microlens placed optimally ...

sensor = mlAnalyzeArrayEtendue(sensor,'optimal');
plotSensorEtendue(sensor);
title('Microlens placed optimally on each pixel')

%% Here is the optimal offset calculation

cra       = sensorGet(sensor,'cra degrees');  % Chief ray angle
rayAngles = linspace(0,max(cra(:)),10);       % How many angles to sample

mlens  = sensorGet(sensor,'microlens');
pixel  = sensorGet(sensor,'pixel');
offset = zeros(1,length(rayAngles));
focalLength = oiGet(oi,'optics focal length','meters');

for ii=1:length(rayAngles)
    mlens       = mlensSet(mlens,'chief ray angle',rayAngles(ii),focalLength);
    offset(ii)  = mlensGet(mlens,'optimal offset','microns');
end

vcNewGraphWin;
plot(rayAngles,offset,'k-o');
xlabel('Ray angle (deg)'); ylabel('Offset towards center (um)');
title('Optimal offset')
grid on

%% Now for the whole sensor array
offsets = mlensGet(mlens,'optimal offsets',sensor);  % Units are microns
sSupport = sensorGet(sensor,'spatial support','um');

vcNewGraphWin;
mesh(sSupport.y,sSupport.x,offsets);
xlabel('Sensor position (um)'); ylabel('Sensor position (um)');
zlabel('Offset towards center (um)')

%% What happens when we change the microlens fnumber?
mlens0  = sensorGet(sensor,'microlens');
sSupport = sensorGet(sensor,'spatial support','um');

fnumber = mlensGet(mlens0,'ml fnumber');
mlens1 = mlensSet(mlens0,'ml fnumber',0.5*fnumber);
mlens1 = mlensSet(mlens1,'name','Half fnumber');

vcNewGraphWin([],'tall');

offsets0 = mlensGet(mlens0,'optimal offsets');  % Units are microns
subplot(2,1,1), mesh(sSupport.y,sSupport.x,offsets0);
xlabel('Sensor position (um)'); ylabel('Sensor position (um)');
zlabel('Offset towards center (um)')
title(sprintf('ml fnumber %.2f',mlensGet(mlens0,'ml fnumber')));

offsets1 = mlensGet(mlens1,'optimal offsets');  % Units are microns
subplot(2,1,2), mesh(sSupport.y,sSupport.x,offsets1);
xlabel('Sensor position (um)'); ylabel('Sensor position (um)');
zlabel('Offset towards center (um)');
title(sprintf('ml fnumber %.2f',mlensGet(mlens1,'ml fnumber')));

% How different is the largest offset (in um)?
max(abs(offsets0(:) - offsets1(:)))

%% What happens when we change the source optics fnumber?

vcNewGraphWin([],'tall');

mlens = mlensSet(mlens,'source fnumber',4);
offsets0 = mlensGet(mlens,'optimal offsets');  % Units are microns
subplot(2,1,1), mesh(sSupport.y,sSupport.x,offsets0);
xlabel('Sensor position (um)'); ylabel('Sensor position (um)');
zlabel('Microlens offset (um)')
title(sprintf('F/# %.1f',mlensGet(mlens,'source fnumber')));

sensor = sensorSet(sensor,'microlens',mlens1);
mlens = mlensSet(mlens,'source fnumber',16);
offsets1 = mlensGet(mlens,'optimal offsets');  % Units are microns
subplot(2,1,2), mesh(sSupport.y,sSupport.x,offsets1);
xlabel('Sensor position (um)'); ylabel('Sensor position (um)');
zlabel('Microlens offset (um)')
title(sprintf('F/# %.1f',mlensGet(mlens,'source fnumber')));

max(abs(offsets0(:) - offsets1(:)))

%% Illustrate radiance for different chief ray angles

vcNewGraphWin([],'tall');

% Initialize the lens
mlens = mlensCreate;
mlens = mlensSet(mlens,'ml fnumber',8);  % Make a blurry microlens

% Select parameters for plotting
chiefrays = (-10:5:10);
nRays = length(chiefrays);
for ii=1:nRays
    mlens = mlensSet(mlens,'chief ray angle',chiefrays(ii));
    mlens = mlRadiance(mlens);
    x = mlensGet(mlens,'x coordinate');
    
    subplot(nRays,1,ii)
    imagesc(x,x,mlensGet(mlens,'pixel irradiance'));
    axis image; h = hot(256); colormap(h(50:220,:)); grid on
    xlabel('Position (um)'); ylabel('Position (um)');
    title(sprintf('%i deg',chiefrays(ii)));
end

%%
