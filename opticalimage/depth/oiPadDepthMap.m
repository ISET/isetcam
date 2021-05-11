function dMap = oiPadDepthMap(scene, invert)
% Pad the scene depth map into the oi depth map
%
%  dMap = oiPadDepthMap(scene)
%
% It is also possible to extract the center part of the depth map, without
% the padding.
%
% ....

% Check variables
if ieNotDefined('invert'), invert = 0; end

if ~invert
    dMap = sceneGet(scene, 'depth map');
    sSize = sceneGet(scene, 'size');
    padSize = round(sSize/8);
    padSize(3) = 0;
    padval = 0;
    direction = 'both';
    dMap = padarray(dMap, padSize, padval, direction);
    % figure; imagesc(dMap)
else
    dMap = oiGet(oi, 'depth map');
    [r, c] = size(dMap);
    center = round(r/2);
    cDepth = dMap(center, :);
    hData = (cDepth > 0);
    hData = double(hData);
    center = round(c/2);
    cDepth = dMap(:, center);
    vData = (cDepth > 0);
    vData = double(vData);
    gData = logical(hData(:)*vData(:)');
    figure; imagesc(gData)
    oMap = dMap(gData);
    %    figure; imagesc(oMap)
end

end