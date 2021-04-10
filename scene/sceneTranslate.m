function scene = sceneTranslate(scene,dxy,fillValues)
% Translate a scene
%
%   scene = sceneTranslate(scene,dxy);
%
%  Translate a spectral scene data by dxy degrees. The trailing region is
%  filled with zeros. The translation is arranged to be at the
%  discrete step size of the scene to avoid blurring by interpolation.  I
%  suppose we could allow interpolation.
%
%
% DJC: Update to imageTranslate should now allow sub-pixel interp
%      so I think we can remove the round() call if that works
%
% scene:  Spectral scene
% dxy:    (x,y) displacement in degrees
% fillValue: value to use for areas that need to be filled in
%
% Example:
%   scene = sceneCreate;
%   dxy = [0,1];   % In degrees
%   scene = sceneTranslate(scene,dxy);
%   ieAddObject(scene); sceneWindow;
%
% See also: imageTranslate, imageRotate, s_sensorRollingShutter
%
% Copyright Imageval, LLC, 2014

if ~exist('scene','var'), error('Scene required.'); end
if ~exist('dxy','var'),   error('x,y displacement required'); end
if ~exist('fillValues', 'var'), fillValues = 0; end % default

% Calculate the shift in pixels in the row/col directions
% dxy(2) = rowShift*degPerPixel;
% dxy(1) = colShift*degPerPixel;
degPerPixel = sceneGet(scene,'h angular resolution');

% we can now do sub-pixel shifts
% shift = round(dxy/degPerPixel);   % Discretize step size here
shift = dxy/degPerPixel;   % Discretize step size here
p = sceneGet(scene,'photons');
p = imageTranslate(p,shift, fillValues);

scene = sceneSet(scene,'photons',p);
% ieAddObject(scene); sceneWindow;

end

