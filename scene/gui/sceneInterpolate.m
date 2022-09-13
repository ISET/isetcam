function scene = sceneInterpolate(scene,newSize)
% Spatially interpolate the scene radiance photons
%
% Synopsis
%     scene = sceneInterpolate(scene,newSize)
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
%   newSize - New number of rows and cols
%
% See also
%   sceneSpatialResample - Similar but specified as new sample spacing
%

% Examples:
%{
 scene = sceneCreate;
 sceneWindow(scene);
 sz = sceneGet(scene,'size');
 scene2 = sceneInterpolate(scene,[1,2].*sz);
 sceneWindow(scene2);
%}
%% Parse
if ieNotDefined('newSize'), error('sFactor must be defined'); end
if ieNotDefined('scene'), error('scene must be defined'); end

r = sceneGet(scene,'rows');
c = sceneGet(scene,'cols');

if numel(newSize) == 1, newSize = [newSize,newSize]; end
newRow = newSize(1); newCol = newSize(2);

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
