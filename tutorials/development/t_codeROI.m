%% t_codeROI
%
% We review how to retrieve data from a region of interest from the scene,
% oi, sensor or image processor.
%
% ISET has a few routines that manage simple, rectangular ROIs.
%
% TODO:  Add ieDrawShape
% Copyright Imageval Consulting, LLC, 2013

%%
ieInit;

%% Build a test scene
scene = sceneCreate;
sceneWindow2(scene);

%% Select a region using the mouse

% The format of a rect is
%   [colmin,rowmin,width,height]
[roiLocs,roi] = ieROISelect(scene);
rect = round(roi.Position);

% If you know the rect, and want to recover the roiLocs, use this
% roiLocs2 = ieRect2Locs(rect);
% isequal(roiLocs,roiLocs2)

%% Get data from the object

% The data are returned in XW Format.
% In this case, every row is the SPD of some point
roiData = vcGetROIData(scene,roiLocs,'photons');

% To convert the roiData back to a little square region run
spd = XW2RGBFormat(roiData,rect(4)+1,rect(3)+1);
ieNewGraphWin;
rgb = imageSPD(spd,sceneGet(scene,'wave'));
imagescRGB(rgb);


%% The same method can be used with an OI

oi = oiCreate;
oi = oiCompute(oi,scene);
ieAddObject(oi); oiWindow;
[roiLocs,rect] = vcROISelect(oi);
roiData = vcGetROIData(oi,roiLocs,'photons');
spd = XW2RGBFormat(roiData,rect(4)+1,rect(3)+1);
vcNewGraphWin; imageSPD(spd,sceneGet(scene,'wave'));

%% With a sensor, the data are different.
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,8);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;
[roiLocs,rect] = vcROISelect(sensor);

% The sensor roiData has NaNs at all the positions where the sensor is
% missing.  Matlab handles plotting these data, even so
roiData = vcGetROIData(sensor,roiLocs,'electrons');
electrons = XW2RGBFormat(roiData,rect(4)+1,rect(3)+1);
vcNewGraphWin; imagescRGB(electrons);

%% Add a circle to the image processor
ip = ipCreate;
ip = ipCompute(ip,sensor);
ieAddObject(ip); ipWindow;

c = ipGet(ip,'center');
radius = c(1)/4;
h = ieDrawShape(ip,'circle',c(1:2),radius);
set(h,'color',[0 0 1],'linewidth',3);

%%