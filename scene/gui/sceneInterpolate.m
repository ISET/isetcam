function scene = sceneInterpolate(scene,sFactor)
% Spatially interpolate the scene radiance data by sFactor
%
% Synopsis
%     scene = sceneInterpolate(scene,sFactor)
%
% Description:
%
%  Spatially interpolate data in a scene structure by a scale factor
%  (sFactor). If sFactor is a single number, then it is a scale factor
%  that is applied to both the rows and the columns. The result is
%  rounded to an integer. If sFactor is a 2D vector, the two entries
%  are applied separately to the row and column dimensions.
%
% Inputs:
%   scene
%   sFactor - Scale factor for rows and cols
%
% See also
%   sceneSpatialResample

if ieNotDefined('sFactor'), error('sFactor must be defined'); end
if ieNotDefined('scene'), scene = vcGetObject('scene'); end

r = sceneGet(scene,'rows');
c = sceneGet(scene,'cols');

if length(sFactor) == 1
    newRow = round(r*sFactor); newCol = round(c*sFactor);
elseif length(sFactor) == 2
    newRow = round((sFactor(1)*r)); newCol = round(c*sFactor(2));
else
    error('Incorrect sFactor.');
end

if checkfields(scene,'data','photons')
    photons = sceneGet(scene,'photons');
    scene = sceneClearData(scene);
    photons = imageInterpolate(photons,newRow,newCol);
    scene = sceneSet(scene,'photons',photons);
end

if checkfields(scene,'depthMap')
    dMap = sceneGet(scene,'depthMap');
    dMap = imageInterpolate(dMap,newRow,newCol);
    scene = sceneSet(scene,'depthMap',dMap);
end

% Make sure luminance is consistent with the new data.
[luminance, meanL] = sceneCalculateLuminance(scene);
scene = sceneSet(scene,'luminance',luminance);
scene = sceneSet(scene,'meanLuminance',meanL);

% Check if the illumination is spectral spatial, and if yes then
% spatially interpolate.

end
