function dMap = oiPadDepthMap(scene,invert,varargin)
% Pad the scene depth map into the oi depth map
%
% Synopsis
%  dMap = oiPadDepthMap(scene)
%
% Brief
%   The depth map of the scene also describes the depth map of the
%   optical image.  
%
% Inputs
%  scene  - The scene with the depth map
%  invert - Not sure what this does
%
% Optional key/val
%  pad - Pad method, which should align with oiCompute's pad method.
%
% Return
%  dMap - The depth map
%
% Description
%  It is also possible to extract the center part of the depth map, without
%  the padding.
%
% See also
%   oiCrop

%% Check variables
if ieNotDefined('invert'), invert = 0; end

if ~invert
    % Why are w
    dMap    = sceneGet(scene,'depth map');
    sSize   = sceneGet(scene,'size');
    padSize = round(sSize/8); padSize(3) = 0;
    padval  = 0;
    direction = 'both';
    dMap = padarray(dMap,padSize,padval,direction);
    % figure; imagesc(dMap)
else
    % What is this?  There is no oi.  Do we ever get here?  Seems not.
    warning('strange oiPadDepthMap case.')
    dMap = oiGet(oi,'depth map');
    [r,c] = size(dMap);
    center = round(r/2); cDepth = dMap(center,:);
    hData = (cDepth > 0); hData = double(hData);
    center = round(c/2); cDepth = dMap(:,center);
    vData = (cDepth > 0); vData = double(vData);
    gData = logical(hData(:)*vData(:)');
    figure; imagesc(gData)
    dMap = dMap(gData);
    %    figure; imagesc(dMap)
end

end