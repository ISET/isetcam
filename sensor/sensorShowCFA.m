function [fig, cfaImg] = sensorShowCFA(sensor, fullArray, app, nBlocks)
%Create an image illustrating the sensor CFA spatial pattern
%
%    [fig, cfaImg] = sensorShowCFA(sensor,[fullArray = 0],app, nBlocks)
%
% The plotted colors are based on the letter names of the color filters
% (not the spectra).
%
%  sensor:    Sensor object
%  fullArray: Typically an image of just the super pixel pattern is shown.
%             If fullArray is true, makes an image showing the full pattern.
%  app:       app for the sensorWindow that has imgCFA as a slot
%  nBlocks:   Number of cfa blocks to render
%
% Return
%   fig:    Handle to the figure where data are rendered
%   cfaImg: RGB image of the CFA array
%
% Copyright ImagEval Consultants, LLC, 2010
%
% See also: sensorPlot, sensorImageColorArray, sensorDetermineCFA
%

% Examples:
%{
s = sceneCreate; oi = oiCreate; sensor = sensorCreate;
oi = oiCompute(oi,s); sensor = sensorCompute(sensor,oi);
img = sensorShowCFA(sensor,false);
sensor = sensorCreate('human');
sensorShowCFA(sensor);
%}

%%
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('fullArray'), fullArray = false; end
if ieNotDefined('app')
    app = [];
end
if ieNotDefined('nBlocks'), nBlocks = 1; end

%% Indexed color image of the sensor detectors.

% The colors in mp are based on the letters in 'plot filter colors'
[cfaSmall, mp] = sensorImageColorArray(sensorDetermineCFA(sensor));

if fullArray
    % Set the image so each pixel is 3x3
    s = 3;
    cfaImg = imageIncreaseImageRGBSize(cfaSmall, s);
else
    % Get the first block
    p = sensorGet(sensor, 'pattern');

    % Number of blocks times the size
    sz = size(p) * nBlocks;
    cfaSmall = cfaSmall(1:sz(1), 1:sz(2));

    % Make the image pretty big.  If it is a human sensor, the block is
    % already quite big, so we don't make it too much bigger.
    if max(size(cfaSmall, 1)) < 64, s = 192 / round(size(cfaSmall, 1));
    else, s = 3;
    end
    cfaImg = imageIncreaseImageRGBSize(cfaSmall, s);
end

%% Draw the CFA

cfaImg = ind2rgb(cfaImg, mp);
if isempty(app)
    tSizeFlag = true;
    % Set up in a new window
    fig = ieNewGraphWin;
    set(fig, 'Name', sensorGet(sensor, 'name'), 'menubar', 'None');
    image(cfaImg); axis off
else
    app.imageCFA.ImageSource = cfaImg;
    fig = app.figure1;
    tSizeFlag = false;
end

if tSizeFlag
    if fullArray
        %  truesize(fig);
    else
        truesize(fig, [92, 92]);
    end
end

end
