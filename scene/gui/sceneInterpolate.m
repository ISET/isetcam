function scene = sceneInterpolate(scene,sFactor)
% Spatially interpolate the scene radiance photons
%
% Synopsis
%     scene = sceneInterpolate(scene,sFactor)
%
% Description:
%  Spatially interpolate photon data in a scene structure by a scale factor
%  (sFactor). If sFactor is a single number, then it is a scale factor
%  that is applied to both the rows and the columns. The result is
%  rounded to an integer. If sFactor is 2D, the entries are applied
%  separately to the row and column dimensions.
%
%  If the illuminant is spatial-spectral, it is spatially interpolated
%  as well.
%
% Inputs:
%   scene  - ISETCam scene
%   sFactor - Scale factor for rows and cols
%
% See also
%   sceneSpatialResample - Similar but specified as new sample spacing

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
switch sceneGet(scene,'illuminant format')
    case 'spatial spectral'
        photons = sceneGet(scene,'illuminant photons');
        photons = imageInterpolate(photons,newRow,newCol);
        scene = sceneSet(scene,'illuminant photons',photons);
    otherwise
        % Do nothing
end

end
