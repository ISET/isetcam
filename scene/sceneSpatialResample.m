function scene = sceneSpatialResample(scene,dx,units,method)
% Spatial resample all wavebands of a scene
%
% Synopsis
%   scene = spatialResample(scene,dx,'units','method')
%
% Description:
%   The scene photons are represented at a spatial sampling separation
%   in meters. This function resamples the photon data to a different
%   spatial sampling density.  This changes the number of row and
%   column samples, but leaves the total size of the scene the same.
%
% Inputs
%   scene:   ISET scene
%   dx:      New sample distance.  Default is meters, but you can specify units
%   method:  linear, cubic or spline interpolation (default = 'linear')
%
% Return
%   scene
%
% See also: 
%    sceneSpatialSupport, oiSpatialResample
%

% Examples:
%{
 scene = sceneCreate; 
 scene = sceneSet(scene,'fov',1);
 sceneWindow(scene);
 sRes = sceneGet(scene,'spatial resolution')
 scene = sceneSpatialResample(scene,sRes(1)*2);
 sceneWindow(scene);
%}

%% Set up parameters
if ieNotDefined('scene'),  error('scene required'); end
if ieNotDefined('units'),  units  = 'm'; end
if ieNotDefined('method'), method = 'linear'; end
% Always work in meters
dx = dx/ieUnitScaleFactor(units);

% Find the spatial support of the current scene, and its max/min
ss = sceneSpatialSupport(scene,'meters');   % x and y spatial support
xmin = min(ss.x(:)); xmax = max(ss.x(:));
ymin = min(ss.y(:)); ymax = max(ss.y(:));

% Set up the new spatial support
% We want height/rows = dx exactly, if possible
% We get to set the FOV to make this work out.
xN = xmin:dx:xmax;
yN = ymin:dx:ymax;

% fprintf('Current  dx = %f meters\n',ss.y(2) - ss.y(1));
% fprintf('Proposed dx = %f meters\n',dx);
% fprintf('New scene size %d (rows) %d (cols)\n',length(yN),length(xN));
if length(xN) > 1000 || length(yN) > 1000
    fprintf('Very large scene.  Any key to continue\n');
    pause
end

%% Interpolate the image for each waveband
nWave = sceneGet(scene,'nwave');
wave  = sceneGet(scene,'wave');

% Precompute meshgrid for speed outside of loop
[X,Y]   = meshgrid(ss.x,ss.y);
[Xq,Yq] = meshgrid(xN,yN);

photonsN = zeros(length(yN),length(xN),nWave);
for ii=1:nWave
    photons = sceneGet(scene,'photons',wave(ii));
    photonsN(:,:,ii) = interp2(X,Y,photons,Xq,Yq,method);
end

% Change up the photons and thus the row/col
scene = sceneSet(scene,'photons',photonsN);
n = sceneGet(scene,'name');
scene = sceneSet(scene,'name',sprintf('%s-%s',n,method));

% Now adjust the FOV so that the dx works out perfectly
sr    = sceneGet(scene,'spatial resolution');
fov   = sceneGet(scene,'fov');
scene = sceneSet(scene,'fov',fov*dx/sr(2));

end

