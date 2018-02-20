%% t_cameraAntiAliasing
%
% Illustrate the effect of the anti-aliasing filter.
%
% Copyright Imageval Consulting, LLC, 2015

%%
ieInit

%% Create a high frequency orientation scene

s = sceneCreate('freq orient',512);
s = sceneSet(s,'h fov',6);
ieAddObject(s); sceneWindow;

%% Create a high resolution optical image (diffraction limited, f 2.0)

oi = oiCreate;
oi = oiSet(oi,'optics fnumber',2);
oi = oiCompute(oi,s);
ieAddObject(oi); oiWindow;

%% Create a 1.5 um resolution sensor

sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size constant fill factor',[1.5 1.5]*1e-6);
sensor = sensorSetSizeToFOV(sensor,5,s,oi);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;

%% Basic image processing

ip = ipCreate;
ip = ipCompute(ip,sensor);
ip = ipSet(ip,'name','No anti-aliasing filter');
ieAddObject(ip); ipWindow;

%% Insert an anti-aliasing filter

% Blur FWHM one pixel size
oi = oiSet(oi,'diffuser method','blur');
pSize = sensorGet(sensor,'pixel size');
oi = oiSet(oi,'diffuser blur', pSize(1));
ieAddObject(oi); oiWindow;

%% Compute and show
oi     = oiCompute(oi,s);
sensor = sensorCompute(sensor,oi);
ip = ipCompute(ip,sensor);
ip = ipSet(ip,'name','Anti-aliasing blur filter');
ieAddObject(ip); ipWindow;

%%  Use a birefringent anti-aliasing filter
oi = oiSet(oi,'diffuser method','birefringent');
ieAddObject(oi); oiWindow;

%% Compute and show
oi     = oiCompute(oi,s);
sensor = sensorCompute(sensor,oi);
ip = ipCompute(ip,sensor);
ip = ipSet(ip,'name','Anti-aliasing birefingent filter');
ieAddObject(ip); ipWindow;

%%