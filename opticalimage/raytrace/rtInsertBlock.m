function img = rtInsertBlock(img,filteredData,blockSamples,blockPadding,rBlock,cBlock)
% Insert a block of data filtered into the irradiance image
%
%    img = rtInsertBlock(img,filteredData,blockSamples,blockPadding,rBlock,cBlock)
%
% This is used to build up the output image in the ray trace.  The filtered
% data are the optical image irradiance blurred by the PSF of the optics.
% The rBlock and cBlock define which block we are managing.  The
% blockSamples defines the number of spatial samples (row,col) in each
% block.  The blockPadding defines how much we pad the blocks when we
% filter the data.  Usually we pad each dimension by the amount of
% blockSamples.
%
%

dataSize = size(filteredData);

if rBlock == 1, rStart = 1;
else rStart = (rBlock-1)*blockSamples(1) + 1;
end
rList = rStart + [0:(dataSize(1)-1)];

if cBlock == 1, cStart = 1;
else cStart = (cBlock-1)*blockSamples(2) + 1;
end
cList = cStart + [0:(dataSize(2)-1)];

img(rList,cList) = img(rList,cList) + filteredData;

return;