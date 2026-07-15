%% Simulate exposure bracketing with sensorCompute
%
% Exposure bracketing acquires a series of exposures. You can simulate
% exposure bracketing by setting the exposure time to be a vector of
% numbers.  The calculation is illustrated here.  You can then visualize
% all of the different exposures in the sensor window, which has a slider
% that lets you scan through the different exposures.
%
% The code first illustrates working with *scene, oi, sensor* directly.
% Then it shows the same calculation using a *camera* object.
%
% See also:  sensorCompute, cameraCreate, cameraWindow
%
% Copyright Imageval, LLC, 2013

%%
ieInit

%% Create a scene, oi, and sensor

% This could be cameraCreate, but for teaching being explicit about the
% objects seems better.
scene  = sceneCreate;
scene  = sceneSet(scene,'fov',4);

oi     = oiCreate;
oi     = oiCompute(oi,scene);
sensor = sensorCreate;

%% Set a range of exposure times

T1 = [0.02 0.04 0.08 0.16 0.32];  % Times
sensor     = sensorSet(sensor,'Exp Time',T1);
nExposures = length(T1);

% Compute all the exposure durations
exposurePlane = floor(nExposures/2) + 1;
sensor = sensorSet(sensor,'exposure plane',exposurePlane);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);

% Notice on the lower right the Bracket, and how there is a slider on the
% lower left that is labeled 'Exposure'. Adjust the slider on the lower
% left of the window to show a different exposure duration.
sensorWindow;

%% Display the shortest exposure

sensor = sensorSet(sensor,'exposure plane',1);
vcReplaceObject(sensor); sensorWindow;

%% Longest
sensor = sensorSet(sensor,'exposure plane',5);
vcReplaceObject(sensor); sensorWindow;

%% This is very short code when you work with a camera object

camera = cameraCreate;
camera = cameraSet(camera,'sensor exp time',T1);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%% Optional extension: HDR with multiple pixel sizes
%
% This extension simulates several monochrome sensors at different pixel
% sizes while keeping the dye area fixed. The resulting image stack is
% useful for HDR-style fusion experiments.

fName = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs.mat');
if exist(fName,'file')
	hdrScene = sceneFromFile(fName,'multispectral',200);
	hdrOi = oiCreate;
	hdrOi = oiCompute(hdrOi,hdrScene);

	pSize = [1 2 4];
	dyeSizeMicrons = 512;
	baseSensor = sensorCreate('monochrome');
	baseSensor = sensorSet(baseSensor,'expTime',0.003);
	baseProcessor = ipCreate;

	sensorSetCell = cell(numel(pSize),1);
	ipSetCell = cell(numel(pSize),1);
	for ii = 1:numel(pSize)
		sensorSetCell{ii} = sensorSet(baseSensor,'pixel size constant fill factor',[pSize(ii) pSize(ii)]*1e-6);
		sensorSetCell{ii} = sensorSet(sensorSetCell{ii},'rows',round(dyeSizeMicrons/pSize(ii)));
		sensorSetCell{ii} = sensorSet(sensorSetCell{ii},'cols',round(dyeSizeMicrons/pSize(ii)));
		sensorSetCell{ii} = sensorCompute(sensorSetCell{ii},hdrOi);
		sensorSetCell{ii} = sensorSet(sensorSetCell{ii},'name',sprintf('pSize %.1f',pSize(ii)));
		ieAddObject(sensorSetCell{ii});

		ipSetCell{ii} = ipCompute(baseProcessor,sensorSetCell{ii});
		ipSetCell{ii} = ipSet(ipSetCell{ii},'name',sprintf('pSize %.1f',pSize(ii)));
		ieAddObject(ipSetCell{ii});
	end

	imageMultiview('ip',1:numel(pSize),true);

	ii = 2;
	volts = sensorGet(sensorSetCell{ii},'volts'); %#ok<NASGU>
	ii = 1;
	rgbResult = ipGet(ipSetCell{ii},'result'); %#ok<NASGU>
else
	warning('HDR source file not found; skipping pixel-size extension: %s',fName);
end

%%