function img = sensorShowImage(sensor,gam,scaleMax,figNum)
% Display the image in a scene structure.
%
%    img = sensorShowImage(sensor,[gam=1],[scaleMax=0],[figNum])
%
% The display is shown as a r,g,b or c,m,y or monochrome array that
% indicates the values of individual pixels in the sensor, depending on
% the sensor type. 
%
% Image appearance -
%
% In the other windows we convert the display image into an sRGB format by
% first calculating XYZ values and then using xyz2srgb. In this window,
% however, we do not have XYZ values at every pixel. Rather, we have RGB
% values that are linear with respect to the number of volts at the pixel.
% To preserve the general appearance, we treat these values as linear rgb
% and use lrgb2srgb() to calculate the displayed image.  This is
% implemented in sensorData2Image.
%
% The final display can be modified by the gamma parameter is read from the
% figure setting. 
%  
% The data are either scaled to a maximum of the voltage swing (default) or
% if scaleMax = 1 (Scale button is selected in the window) the image data
% are scaled to fill up the display range. This option is useful for small
% voltage values compared to the voltage swing, say in the simulation of
% human cone responses.
%
% Examples:
%   sensorShowImage(sensor,gam); 
%   sensorShowImage(sensor); 
%
% See also:  sensorData2Image, imageShowImage, sceneShowImage, oiShowImage
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('gam'),      gam = ieSessionGet('sensor gamma'); end
if ieNotDefined('scaleMax'), scaleMax = 0; end
if ieNotDefined('figNum'),   figNum = ieSessionGet('sensor window'); end

cla;
if isempty(sensor),return; end

% We have the voltage or digital values and we want to render them into an
% image. We handle various types of cases, include the multiple exposure
% case.
img = sensorData2Image(sensor,'dv or volts',gam,scaleMax);

% If figNum is false, we don't display.  Otherwise, we show the data in
% the currently selected figure.
if ~isempty(img)
    % If the sensor is monochrome, the img is a matrix, not RGB.
    if ismatrix(img), img = repmat(img,[1,1,3]); end

    if ~isequal(figNum,0), image(img); axis image; axis off; end
    if (sensorGet(sensor,'nSensors') == 1), colormap(gray(256)); end
end


end