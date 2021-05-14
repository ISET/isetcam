%% Illustrates how to write out an image to a file from the IP
%
% After computing images, you may want to write them in a simple
% format to mail and show to colleagues.  Each of the objects has
% a method for extracting the image that is shown in the GUI
% window. Here, we illustrate the method for the ip structure.
%
% Check the other calls, such as: sceneGet(scene,'rgb image');
%
% See also: ipGet
%
% (c) Imageval, LLC 2014

%%
ieInit

%% Cook up some data
scene  = sceneCreate('reflectance chart');
scene  = sceneSet(scene,'hfov',10);

oi     = oiCreate;
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,10,oi);
ip     = ipCreate;

oi     = oiCompute(oi,scene);
sensor = sensorCompute(sensor,oi);
ip     = ipCompute(ip,sensor);

%% Get data in some format from the image processor

% The sRGB is a standard display format, and this is what we show in the
% window.
result = ipGet(ip,'srgb');
vcNewGraphWin;
image(result)

%% It is also possible to get the linear RGB values
%
% These are stored in the result, and they do not correct for the
% display characteristics.
raw = ipGet(ip,'result');
vcNewGraphWin;
image(raw)

%% Once you have the data, use standard Matlab utilities to write the file
fname = 'deleteMe.jpg';
imwrite(result,fname,'jpeg');
delete(fname);

%%
