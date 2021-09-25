function sSupport = sceneSpatialSupport(scene,units)
%Calculate the spatial positions of the scene sample locations
%
%     sSupport = sceneSpatialSupport(scene',[units = 'meters'] )
%
% Determine the spatial positions of the sample positions (spatial support)
% of a scene.  These values correspond to position the scene. The default
% spatial units are returned as part of a structure in x and y positions in
% meters.
%
% See also: oiSpatialSupport
%
% Examples:
%  sSupportmm = sceneSpatialSupport(scene,'millimeters');
%  sSupportum = sceneSpatialSupport(scene,'microns');
%  sSupportm  = sceneSpatialSupport(scene);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('units'), units = 'meters'; end

sr = sceneGet(scene,'spatial resolution',units);
nRows = sceneGet(scene,'rows');
nCols = sceneGet(scene,'cols');

sSupport.y = linspace(-nRows*sr(1)/2 + sr(1)/2, nRows*sr(1)/2 - sr(1)/2,nRows);
sSupport.x = linspace(-nCols*sr(2)/2 + sr(2)/2, nCols*sr(2)/2 - sr(2)/2,nCols);

return;
