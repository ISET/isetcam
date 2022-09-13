function scene = sceneRotate(scene,deg)
% Rotate a scene
%
%   scene = sceneRotate(scene,rotParam);
%
% Rotate a spectral scene data by deg degrees. Unfilled regions are
% filled with zeros.  The illuminant image is rotated, too.
%
% scene:  Spectral scene
% rotParam:
%      This can either be a string ('cw', 'ccw'), or
%      A numeric value in degrees.  If degrees, then counter clockwise is
%      positive, and clockwise is negative.
%
% Example:
%   scene = sceneCreate('star pattern');
%   deg = 10;
%   scene = sceneRotate(scene,deg);
%   ieAddObject(scene); sceneWindow;
%
% See also: imageTranslate, imageRotate, s_sensorRollingShutter
%
% Copyright Imageval, LLC, 2014

if ~exist('scene','var'), error('Scene required.'); end
if ~exist('deg','var'),   error('Rotation (deg) required'); end

%% Rotate the spectral radiance
p = sceneGet(scene,'photons');
p = imageRotate(p,deg);
scene = sceneSet(scene,'photons',p);

%% Rotate if spatial spectral illumination data

switch ieParamFormat(sceneGet(scene,'illuminant format'))
    case 'spatialspectral'
        p = sceneGet(scene,'illuminant photons');
        p = imageRotate(p,deg);
        scene = sceneSet(scene,'illuminant photons',p);
    otherwise
        % Spectral illuminant, so no need to rotate.
end

end

