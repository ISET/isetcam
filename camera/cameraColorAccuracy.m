function [eAnalysis, camera] = cameraColorAccuracy(camera, lum, varargin)
% Analyze the color accuracy of a camera design
%
% [eAnalysis, camera] = ieCameraColorAccuracy(camera,lum,varargin)
%
% Copyright Imageval, LLC 2012

%% Argument checking here

if ieNotDefined('lum'), lum = 100; end % Candelas for the scene

%% Set up the MCC scene
oi = cameraGet(camera, 'oi');
sensor = cameraGet(camera, 'sensor');
sDist = 1000; % distance of imager from scene (m)
fov = sensorGet(sensor, 'fov', sDist, oi);

mcc = sceneCreate;

% MCC scene properties
mcc = sceneAdjustLuminance(mcc, lum);
mcc = sceneSet(mcc, 'fov', fov);
mcc = sceneSet(mcc, 'distance', sDist);
% ieAddObject(mcc); sceneWindow;

camera = cameraCompute(camera, mcc);

%% Plot the error metric

ip = cameraGet(camera, 'vci');
ipWindow(ip);

% The mcc image runs all the way horizontally, but is a few pixels short in
% the y-dimension.
cp = chartCornerpoints(ip, true);
ip = ipSet(ip, 'chart corner points', cp);
macbethDrawRects(ip, 'on')

% If you change the size of the sensor or other spatial parameters, you may
% have to adjust these.  You can use this routine to interactively click on
% the four corners of the MCC.  See the message in the processor window
% that tells you the order to click on the corners.
%
% [mRGB, mLocs, pSize, pointLoc] = macbethSelect(vci);
%
% You can see the selection of rects for the patches by
%   vci = macbethDrawRects(vci,'on');
% Turn them off with
%   vci = macbethDrawRects(vci,'off');
%

% Compute the delta E values
% This produces a plot with several evaluations of the errors
[macbethLAB, macbethXYZ, deltaE] = macbethColorError(ip, 'D65', cp);
camera = cameraSet(camera, 'ip chart corner points', cp);

% Store results.
eAnalysis.macbethLAB = macbethLAB;
eAnalysis.macbethXYZ = macbethXYZ;
eAnalysis.deltaE = deltaE;
eAnalysis.vci = ip;

end
