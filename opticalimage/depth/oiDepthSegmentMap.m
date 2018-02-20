function idx = oiDepthSegmentMap(oiDmap,depthEdges)
%
%
%
%
%

nEdges = length(depthEdges);
[r,c] = size(oiDmap); 
vMap = zeros(r,c,nEdges);

for ii=1:nEdges, vMap(:,:,ii) = oiDmap - depthEdges(ii); end
% imagesc(oiDmap)

[v,idx] = min(abs(vMap),[],3);
% figure; imagesc(idx)

return
