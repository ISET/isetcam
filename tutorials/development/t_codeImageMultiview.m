%% t_imageMultiview
%
% Illustrate how to display multiple RGB images from the
% scene/oi/sensor/vci objects.
%
% We fill up the various GUI windows with several examples.  Then we show
% how to bring up the RGB images into separate windows.
%
% Copyright Imageval LLC, 2013

%%
ieInit

%% To start debugging I ran s_imageIlluminantCorrection
%
% This provides  windows with multiple examples
% It takes a little while.
s_ipIlluminantCorrection

%%  Get a list of the objects
%

% This example shows several of the scene images.  No user interaction
% required.
objType = 'scene';
whichObj = [2 3 5];
imageMultiview(objType,whichObj);

singleWindow = true;
imageMultiview(objType,whichObj,singleWindow);

%% This one allows you to select which ones you want to compare
oiWindow;
singleWindow = true;
imageMultiview('oi',[],singleWindow);

%%
sensorWindow;
imageMultiview('sensor',[ 1 4]);

%%  Show images in a single window, rather than in separate windows.
ipWindow
singleWindow = true;
imageMultiview('vci',[1 2 3 4],singleWindow);

%% End
