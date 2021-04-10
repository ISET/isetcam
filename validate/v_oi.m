%% Test optical image functions
%
% Copyright Imageval LLC, 2009

%% Diffraction limited simulation properties
oi = oiCreate;
oiPlot(oi,'otf',[],550);
oiPlot(oi,'otf',[],450);

%% Human optics
oi = oiCreate('human');
oiPlot(oi,'psf',[],420);
oiPlot(oi,'psf',[],550);

%% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate;
oi = oiCompute(oi,scene);
oiPlot(oi,'illuminance mesh linear');

%% Try spatial resampling

v_sceneSpatialResample

%% Check GUI control
oiWindow(oi); pause(0.2);

oiSet(oi,'gamma',1);
oiSet(oi,'gamma',0.4); pause(0.5)
oiSet(oi,'gamma',1);

%%