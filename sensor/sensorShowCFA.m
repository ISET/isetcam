function [fig, cfaImg] = sensorShowCFA(sensor, app)
%Create an image illustrating the sensor CFA spatial pattern
%
%    [fig, cfaImg] = sensorShowCFA(sensor,[fullArray = 0],app)
%
% Brief description
%  The plotted colors are based on the letter names of the color filters for
%  rgb, rgbw, and wrgb.  Otherwise, they are calculated from the spectral
%  transmittance of the color filters
%
% Inputs
%  sensor:    Sensor object
%  app:       app for the sensorWindow that has imgCFA as a slot
%           (fullArray was recently deleted.  Maybe it should be put back)
%
% Return
%   fig:    Handle to the figure where data are rendered
%   cfaImg: Color image of the CFA array
%
% See also: 
%  sensorPlot, sensorData2Image, sensorDetermineCFA
%

% Examples:
%{
  s = sceneCreate; oi = oiCreate; sensor = sensorCreate;
  oi = oiCompute(oi,s); sensor = sensorCompute(sensor,oi);
  img = sensorShowCFA(sensor);
%}
%{
  sensor = sensorCreate('human');
  sensorShowCFA(sensor);
%}

%%
if ieNotDefined('sensor'),    sensor = vcGetObject('sensor'); end
% if ieNotDefined('fullArray'), fullArray = false; end
if ieNotDefined('app')
    app = [];
end

% Should be a parameter
sScale = 32;

%% Indexed color image of the sensor detectors.

pattern    = sensorGet(sensor,'pattern');
nExposures = sensorGet(sensor,'n exposures');

mxVolts = sensorGet(sensor,'voltage swing');

%% Create an image of the sensor CFA
% If we are in the single exposure case
if nExposures == 1
    ss = sensorSet(sensor,'volts',mxVolts*ones(size(pattern)));
else
    % If we are in the multiple exposure case
    [r,c] = size(pattern);
    ss = sensorSet(sensor,'volts',mxVolts*ones(r,c,nExposures));
end

% The color rendering in sensorData2Image depends on whether we use certain
% filter names (rgb, rgbw, wrgb) and if not then we do our best to
% calculate the color rendering.
%
% If the sensor is monochrome, the color should be an estimate of the
% spectral QE
cfaSmall = sensorData2Image(ss);

% Size scaling should be a parameter.
cfaImg = imageIncreaseImageRGBSize(cfaSmall,sScale);

%% Draw the CFA

if isempty(app)
    % Set up in a new window
    fig = ieNewGraphWin;
    set(fig,'Name', sensorGet(sensor,'name'),'menubar','None');
    image(cfaImg); axis off
else
    % Show it in the sensorWindow app
    app.imageCFA.ImageSource = cfaImg;
    fig = app.figure1;
end

end

