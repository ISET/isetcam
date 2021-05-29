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
%  (fullArray was recently deleted.  Maybe it should be put back)
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
if ieNotDefined('fullArray'), fullArray = false; end
if ieNotDefined('app')
    app = [];
end

% Should be a parameter
sScale = 32;

%% Indexed color image of the sensor detectors.

pattern = sensorGet(sensor,'pattern');
nExposures = sensorGet(sensor,'n exposures');

mxVolts = sensorGet(sensor,'voltage swing');

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
cfaSmall = sensorData2Image(ss);

% Size scaling should be a parameter.
cfaImg = imageIncreaseImageRGBSize(cfaSmall,sScale);


% This was the old approach.  Needs more testing before we delete.
%
%{
[cfaSmall,mp] = sensorImageColorArray(sensorDetermineCFA(sensor));
if fullArray
    % Set the image so each pixel is 3x3
    s = 3;
    cfaImg = imageIncreaseImageRGBSize(cfaSmall,s);
else
    % Get the first block
    p = sensorGet(sensor,'pattern');
    
    % Number of blocks times the size
    sz = size(p)*nBlocks;
    cfaSmall = cfaSmall(1:sz(1),1:sz(2));
    
    % Make the image pretty big.  If it is a human sensor, the block is
    % already quite big, so we don't make it too much bigger.
    if max(size(cfaSmall,1)) < 64, s = 192/round(size(cfaSmall,1));
    else,                           s = 3;
    end
    cfaImg = imageIncreaseImageRGBSize(cfaSmall,s);
end
%}

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

