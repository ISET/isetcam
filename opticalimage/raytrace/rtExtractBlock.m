function [blockData,rList,cList] = rtExtractBlock(irradPad,blockSamples,rBlock,cBlock)
%Extract the (rBlock,cBlock) block from an image. 
%
%     blockData = rtExtractBlock(irradPad,blockSamples,rBlock,cBlock)
%
% In the ray trace code, this routine is used to a single wavelength slice
% from a padded irradiance plane. 
%
%

rStart = (rBlock-1)*blockSamples(1) + 1;
cStart = (cBlock-1)*blockSamples(2) + 1;
rEnd = (rBlock)*blockSamples(1);
cEnd = (cBlock)*blockSamples(2);

if (rEnd > size(irradPad,1)) || (cEnd > size(irradPad,2)) 
    error('Block outside of data range'); 
end
rList = [rStart:rEnd];
cList = [cStart:cEnd];

blockData = irradPad(rList,cList);
%
return;