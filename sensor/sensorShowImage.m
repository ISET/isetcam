function img = sensorShowImage(sensor,gam,scaleMax,app)
% Display the image in a scene structure.
%
% Synopsis
%    img = sensorShowImage(sensor,[gam=1],[scaleMax=0],[app])
%
% Inputs
%   sensor:    ISETCam sensor
%   gam:       Display gamma
%   scaleMax:  Scale to maximum brightness
%   app:       The sensorWindow app.  If this is the number 0, the image is
%              returned but not displayed in the axis (app.imgMain).
%
% Optional key/value
%   N/A
%
% Output
%   img:  RGB image displayed in main axis
%
% Description
%  The main image axis show the r,g,b or c,m,y or monochrome array that
%  indicates the values of individual pixels in the sensor (depending on
%  the sensor type).
%
% Notes Image appearance -
%
%  In the other windows we convert the display image into an sRGB format by
%  first calculating XYZ values and then using xyz2srgb. In this window,
%  however, we do not have XYZ values at every pixel. Rather, we have RGB
%  values that are linear with respect to the number of volts at the pixel.
%  To preserve the general appearance, we treat these values as linear rgb
%  and use lrgb2srgb() to calculate the displayed image.  This is
%  implemented in sensorData2Image.
%
%  The final display can be modified by the gamma parameter is read from the
%  figure setting.
%
%  The data are either scaled to a maximum of the voltage swing (default) or
%  if scaleMax = 1 (Scale button is selected in the window) the image data
%  are scaled to fill up the display range. This option is useful for small
%  voltage values compared to the voltage swing, say in the simulation of
%  human cone responses.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% Examples:
%   sensorShowImage(sensor,gam);
%   sensorShowImage(sensor);
%
% See also:
%   sensorData2Image, imageShowImage, sceneShowImage, oiShowImage
%

if ieNotDefined('gam'),      gam = ieSessionGet('sensor gamma'); end
if ieNotDefined('scaleMax'), scaleMax = 0; end
if ieNotDefined('app')
    app = ieSessionGet('sensor window'); 
    % if we're called without a sensor Window
    % then we can't de-reference through app:
    if ~isequal(app, 0)
        axes(app.imgMain); cla;
    end
end
if isempty(sensor),return; end

% We have the voltage or digital values and we want to render them into an
% image. We handle various types of cases, include the multiple exposure
% case.
img = sensorData2Image(sensor,'dv or volts',gam,scaleMax);

%% We want to handle the cases when the pixel size is not square

% The representation of x and y in plotting the image first came up from
% dual pixel auto focus modeling. Those sensors have spatial pixel sampling
% that is unequal in the two directions.  To make the images appear
% approximately correct in the sensor window, we need to account for the
% pixel spacing.

% This created a bit of a problem when selecting points for plotting.  The
% fix here is imperfect - we are not yet happy with the way this works with
% plotting.  We do not select half of the lines in the high density
% direction.
%
% Still thinking (ZLy, BW)

% We could be showing the image with ss.x and ss.y.  We would then need to
% fix vcLineSelect or vcPointSelect.

% ss  = sensorGet(sensor,'spatial support');

% We assign a value that is not the position, but rather a 'rough' column
% or 'row' number.
pSize = sensorGet(sensor,'pixel size');
rowcol = sensorGet(sensor,'size');
y = (1:rowcol(1)); x = (1:rowcol(2));
sFactor = pSize(2)/pSize(1);
if sFactor > 1 , y = y/sFactor;  % rows
else,            x = x*sFactor;  % columns
end

% If figNum is false, we don't display.  Otherwise, we show the data in
% the currently selected figure.  We might actively select the axis to be
% safe.
if ~isempty(img)
    % If the sensor is monochrome, the img is a matrix, not RGB.
    if ismatrix(img), img = repmat(img,[1,1,3]); end
    
    % What is this condition on app 0?  Is that do not display?
    if ~isequal(app,0), image(app.imgMain,x,y,img); axis image; axis off; end
    if (sensorGet(sensor,'nSensors') == 1), colormap(gray(256)); end
end

end