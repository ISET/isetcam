function [hdl, cfaImg] = sensorShowCFA(sensor,fullArray, app, nBlocks)
%Create an image illustrating the sensor CFA spatial pattern
%
%    [cfaAxis, cfaImg] = sensorShowCFA(sensor,[fullArray = 0],app, nBlocks)
%
% The plotted colors are based on the letter names of the color filters
% (not the spectra).
%
% sensor:    Sensor object
%  fullArray: Typically an image of just the super pixel pattern is shown.
%             If fullArray is true, makes an image showing the full pattern.
%  app:       app for the sensorWindow that has imgCFA as a slot 
%
% Return
%   hdl:    Handle of the image
%   cfaImg: RGB image of the CFA array 
%
% Example:
%  ieInit; 
%  sensor = sensorCreate; s = sceneCreate; oi = oiCreate;
%  oi = oiCompute(oi,s); sensor = sensorCompute(sensor,oi);
%  ieAddObject(oi); ieAddObject(sensor); hdl = sensorWindow;
%  hdl = sensorShowCFA(sensor,false,hdl);
%
%  sensor = sensorCreate('human');
%  sensorShowCFA(sensor);
%
% See also: sensorPlot, sensorImageColorArray, sensorDetermineCFA
%
% Copyright ImagEval Consultants, LLC, 2010

if ieNotDefined('sensor'),    sensor = vcGetObject('sensor'); end
if ieNotDefined('fullArray'), fullArray = false; end
if ieNotDefined('app')
    % Set up in a new window
    fig = vcNewGraphWin;
    set(fig,'Name', sensorGet(sensor,'name'),'menubar','None');
    tSizeFlag = true;
    hdl = [];
else
    % Set up the sensor window image
    axes(app.imgCFA); axis image; axis off
    tSizeFlag = false;
end
if ieNotDefined('nBlocks'), nBlocks = 1; end

% This is an indexed color image of the sensor detectors.
% The colors in mp are based on the letters in 'plot filter colors'
[cfaImage,mp] = sensorImageColorArray(sensorDetermineCFA(sensor));

if fullArray
    % Set the image so each pixel is 3x3
    s = 3;
    cfaImg = imageIncreaseImageRGBSize(cfaImage,s);
else
    % Get the first block
    p = sensorGet(sensor,'pattern');
    
    % Number of blocks times the size
    sz = size(p)*nBlocks;
    cfaImage = cfaImage(1:sz(1),1:sz(2));
    
    % Make the image pretty big.  If it is a human sensor, the block is
    % already quite big, so we don't make it too much bigger.
    if max(size(cfaImage,1)) < 64, s = 192/round(size(cfaImage,1));
    else                           s = 3;
    end
    cfaImg = imageIncreaseImageRGBSize(cfaImage,s);
end

% Draw the CFA in the figure window (true size)
cfaImg = ind2rgb(cfaImg,mp);
image(cfaImg);
axis image off;

if tSizeFlag, truesize(fig); end

% Set control back to main window in sensorWindow
if exist('hdl','var') && ~isempty(hdl)
    axes(hdl.imgMain);
end

end

