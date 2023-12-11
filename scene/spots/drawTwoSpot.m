function [spotPattern] = drawTwoSpot(twoSpotParams)
% Make an image with indicator values for two rectangular spots with specified contrast.
%
% Synopsis:
%    [spotPattern] = drawTwoSpot(twoSpotParams)
%
% Description:
%    This function will draw a pair of spots (1 and 2) on top of a
%    background. Useful for simulating our increment/decrement summation
%    experiments.
%
%    Spot 1 is upper/right, spot2 lower/left.
%
% Far part of image is set to 0, background is set to 1, spot 1 to 2, spot
% 2 to 3.
%
% The input should be a twoSpotParams structure.  SEe example in function
% for the needed fields.

% History:
%   03/16/21    dhb Wrote it

% Examples:
%{
    clear; close all;
    params.type = 'basic';
    params.spotWidthDegs = 0.0217;
    params.spotHeightDegs = 0.0167;
    params.spotVerticalSepDegs = 0.0167;
    params.spotHorizontalSepDegs = 0;
    params.spotBgDegs = 0.2500;
    params.fovDegs = 0.2500;
    params.pixelsNum = 255;

    spotPattern = drawTwoSpot(params);
    figure; clf;
    imshow(spotPattern/max(spotPattern(:)));
%}

% Set image values
outsideValue = 0;
spotBgValue = 1;
spot1Value = 2;
spot2Value = 3;

% Check type
if (~strcmp(twoSpotParams.type,'basic'))
    error('Wrong type of parameter structure passed');
end

% Get row/col size in pixels
row = twoSpotParams.pixelsNum;
col = twoSpotParams.pixelsNum;
if (row ~= col)
    error('Various bits of code assume square image');
end

% Center pixel
centerRow = round(row/2);
centerCol = round(col/2);

% Get background parameters
spotBgSizePixels = round((row/twoSpotParams.fovDegs)*twoSpotParams.spotBgDegs);

% Create canvas in which to place the spots
spotPattern = outsideValue*ones(row, col);

% Create and put background into canvas
if ~isodd(spotBgSizePixels)
    minusHW = spotBgSizePixels/2-1;
    plusHW = spotBgSizePixels/2;
else 
    minusHW = (spotBgSizePixels-1)/2;
    plusHW = minusHW;
end
spotPattern(centerRow-minusHW:centerRow+plusHW, centerCol-minusHW:centerCol+plusHW) = spotBgValue;

% Create the two stimuli
stimRow = round((row/twoSpotParams.fovDegs)*twoSpotParams.spotHeightDegs);
stimCol = round((col/twoSpotParams.fovDegs)*twoSpotParams.spotWidthDegs);
stimRowSepFull = round((row/twoSpotParams.fovDegs)*twoSpotParams.spotVerticalSepDegs);
stimRowSep = round((row/twoSpotParams.fovDegs)*twoSpotParams.spotVerticalSepDegs/2);
stimColSepFull = round((col/twoSpotParams.fovDegs)*twoSpotParams.spotHorizontalSepDegs);
stimColSep = round((col/twoSpotParams.fovDegs)*twoSpotParams.spotHorizontalSepDegs/2);

if ~isodd(stimRow)
    minusV = stimRow/2;
    plusV = stimRow/2-1;
else 
    minusV = (stimRow-1)/2;
    plusV = minusV;
    
end
if ~isodd(stimCol)
    minusH = stimCol/2;
    plusH = stimCol/2-1;
else 
    minusH = (stimCol-1)/2;
    plusH = minusH;    
end

stim1RowOffset = centerRow-stimRowSep;
stim2RowOffset = centerRow+(stimRowSepFull-stimRowSep);

stim1ColOffset = centerCol+stimColSep;
stim2ColOffset = centerCol-(stimColSepFull-stimColSep);

% Fill in the spots
spotPattern((-minusV:plusV)+stim1RowOffset, ...
    (-minusH:plusH)+stim1ColOffset) = spot1Value;
spotPattern((-minusV:plusV)+stim2RowOffset, ...
    (-minusH:plusH)+stim2ColOffset) = spot2Value;

end