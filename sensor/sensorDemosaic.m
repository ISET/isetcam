function imgs = sensorDemosaic(sensor)
% Demosaic the color channels of a sensor into a series of images
%
% Synopsis
%   imgs = sensorDemosaic(sensor)
%
% Input
%   sensor - ISETCam sensor
%
% Optional key/val pairs
%   N/A
%
% Output
%   imgs - Demosaicked sensor channel images:  (row,col,nChannels)
%
% Description
%   When simulating multispectral sensors we are sometimes interested in
%   seeing the individual channels as images.  This routine converts the
%   sensor channels into demosaicked images that can be shown in a
%   sliceViewer format via sensorPlot
%
% See also
%   sensorPlot, Demosaic
%

% Examples:
%{
scene = sceneCreate; scene = sceneSet(scene,'fov',30);
oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreateIMECSSM4x4vis('rowcol',[300 400]);
sensor = sensorSetSizeToFOV(sensor,30,oi);
sensor = sensorSet(sensor,'auto exp',true);
sensor = sensorCompute(sensor,oi);
imgs = sensorDemosaic(sensor);
T = sensorDisplayTransform(sensor);
lst = 1:16;
ieNewGraphWin;
for ii=1:size(imgs,3)
  theseImgs = imgs;
  theseImgs(:,:,lst ~= ii) = 0;
  img = imageLinearTransform(theseImgs,T);
  imshow(img); pause(0.3)
end

% sliceViewer(imgs);
% sensorWindow(sensor);
%}

%%
if ieNotDefined('sensor'), error('sensor required'); end

%% Do the calculation via the ipCompute route

ip   = ipCreate;
ip   = ipSet(ip,'render demosaic only', true);
ip   = ipCompute(ip,sensor);
imgs = ipGet(ip,'sensor space');

%{
% If we want to show the images with the appropriate color
%
  T = sensorDisplayTransform(sensor);
  img = imageLinearTransform(imgs(:,:,1),T);
%}
end
