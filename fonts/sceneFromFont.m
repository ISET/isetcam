function scene = sceneFromFont(font,dsp,scene, oSample, varargin)
% Create a scene from a font and display
%
%  scene = sceneFromFont(font,[display='LCD-Apple'],[scene], varargin)
%
%  Inputs:
%    font     - font structure, see fontCreate
%    display  - display structure, see displayCreate
%    scene    - scene structure, see sceneCreate
%    oSample  - up-sampling rate
%
%    varargin - more parameters, could include:
%      varargin{1} - pad size for the font bitmap
%      varargin{2} - pad value for the font bitmap
%
% BW/HJ Vistasoft group, 2014

%% Input arguments
if notDefined('font'),    font = fontCreate; end
if notDefined('dsp'), dsp = displayCreate('LCD-Apple'); end
if notDefined('scene'),
    scene = sceneCreate('empty');
    scene = sceneSet(scene,'wave',displayGet(dsp,'wave'));
end
if notDefined('oSample'), oSample = [20 20]; end
if ~isempty(varargin), padsz   = varargin{1}; else padsz = []; end
if length(varargin)>1, padval  = varargin{2}; else padval = []; end

% Initialize the display to match the scene and font properties
if ischar(dsp), dsp = displayCreate(dsp); end
dsp = displaySet(dsp,'wave',sceneGet(scene,'wave'));
if displayGet(dsp,'dpi') ~= fontGet(font,'dpi')
    warning('Adjusting display dpi to match font');
    dsp = displaySet(dsp,'dpi',fontGet(font,'dpi'));
end

%% Compute the high resolution display image
paddedBitmap = fontGet(font,'padded bitmap', padsz, padval);
np = displayGet(dsp, 'n primaries');
paddedBitmap = padarray(paddedBitmap, ...
    [0 0 np - size(paddedBitmap, 3)], 'post');
dRGB       = displayCompute(dsp,paddedBitmap, oSample);
[dRGB,r,c] = RGB2XWFormat(dRGB);
spd  = displayGet(dsp,'spd');
wave = displayGet(dsp,'wave');

% Convert the display radiance (energy) to photons and place in scene
energy = dRGB*spd';
energy = XW2RGBFormat(energy,r,c);
p = Energy2Quanta(wave,energy);
scene = sceneSet(scene, 'photons', p);   % Compressed photons

% ieAddObject(scene); sceneWindow;

%% Adjust the scene to match the display resolution

% Adjust mean luminance to maximum Y value of display, but corrected
% for number of black pixels
wp = displayGet(dsp,'white point');
nPixels = numel(paddedBitmap(:,:,1));
p = paddedBitmap(:,:,2); s = sum(p(:))/nPixels;
scene = sceneAdjustLuminance(scene,wp(2)*s);

dist = 0.5;
scene = sceneSet(scene,'distance',dist);

% Calculate scene width in meters.  Each bitmap is 1 pixel.
dpi     = displayGet(dsp,'dpi');
mPerDot = dpi2mperdot(dpi,'meters');
nDots   = size(paddedBitmap,2);
wMeters = mPerDot*nDots;
fov     = atan2d(wMeters,dist);
scene   = sceneSet(scene,'fov',fov);

% Name it
scene = sceneSet(scene,'name',fontGet(font,'name'));

end
