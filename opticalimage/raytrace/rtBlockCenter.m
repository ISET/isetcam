function blockCenter = rtBlockCenter(rBlock,cBlock,blockSamples)
% Find the center pixel (row,col) of a block given the number of samples
% per block
%

blockCenter(1) = blockSamples(1)*(rBlock - 1/2);
blockCenter(2) = blockSamples(2)*(cBlock - 1/2);

return;