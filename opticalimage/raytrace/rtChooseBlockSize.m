function [nBlocks, blockSamples, irradPadding] = rtChooseBlockSize(scene,oi,optics,stepsFH);
% We find the maximum field height in the scene (diagonal/2).
%     [nBlocks, blockSamples, irradPadding] = rtChooseBlockSize(scene,oi,optics,stepsFH);
%
% This determines the number of field height PSFs we have available.
% Then we make sure we have at least 4 samples per PSF step.
%

if ieNotDefined('stepsFH'), stepsFH = 4; end

rows = sceneGet(scene,'rows');
cols = sceneGet(scene,'cols');

d = (oiGet(oi,'diagonal','mm')/2);               % Maximum scene field height in mm
nHeights = ieFieldHeight2Index(opticsGet(optics,'rtgeomfieldheight','mm'),d);

% Number of block samples to guarantee 2/field height step
nBlocks = (stepsFH*nHeights) + 1;

% Size of the section sample that is a power of 2 and produces at least
% nSamples
blockSamples(1) = 2^ceil(log2(rows/nBlocks));
blockSamples(2) = 2^ceil(log2(cols/nBlocks));

% When we extract the irradiance image, we should padd the row and column
% dimensions by this amount to make the sampling work out well.
irradPadding(1) = nBlocks*blockSamples(1) - rows;
irradPadding(2) = nBlocks*blockSamples(2) - cols;
irradPadding = ceil(irradPadding/2);

return;
