%% The microlens object and window
%
% Most (all?) digital cameras include an array of *microlenses*
% that are placed on the surface of the sensor.  These small
% lenses redirect the rays from the main lens onto the
% photodetector within the pixel. Without the microlens array,
% pixels at the edge of the sensor would not be illuminated
% properly.  The microlens calculations here show the appropriate
% placement of the microlens under different assumptions about
% the main lens.
%
% In light field cameras, which we model in the related CISET
% package, the microlenses sit above a small collection of
% pixels.
%
% ISET includes a microlens object and GUI interface. We
% demonstrate some of its properties here.
%
% See also:   mlensCreate, mlensSet, mlensGet, mlRadiance,
%             mlensWindw, sensorCreate, 
%
% Copyright ImagEval Consultants, LLC, 2015

%% 
ieInit

%% Create oi and sensor

% Default oi
oi = oiCreate; ieAddObject(oi);

% Large field of view
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',30);
ieAddObject(sensor);

%% Illustrate microlens gets and sets

mlens = mlensCreate;

mlensGet(mlens,'name')
mlensGet(mlens,'type')

mlensGet(mlens,'source fnumber')
mlensGet(mlens,'source diameter','meters')
mlensGet(mlens,'source diameter','microns')

mlensGet(mlens,'ml fnumber')
mlensGet(mlens,'ml diameter','meters')
mlensGet(mlens,'ml diameter','microns')

mlensGet(mlens,'source fnumber')
mlensGet(mlens,'chief ray angle')

mlens = mlensSet(mlens,'chief ray angle',10);
mlensGet(mlens,'chief ray angle')

%% Radiance estimates

mlens = mlensCreate;

% Computes the irradiance and various other quantities, storing
% them in the mlens structure itself.
[mlens, psImages] = mlRadiance(mlens);

% Show the distribution as an image
mlIrradianceImage(mlens)

plotML(mlens,'mesh pixel irradiance')

sIrradiance = mlensGet(mlens,'source irradiance');
x = mlensGet(mlens,'x coordinate');
vcNewGraphWin; mesh(x,x,sIrradiance);
h = hot(255); colormap(h(50:250,:)); colorbar;
xlabel('Position (um)');
%%  Bring up the microlens window

microLensWindow;

%%
