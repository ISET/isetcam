function [scene, params] = sceneHarmonic(scene, params, wave)
% Create a scene of a Gaussian windowed harmonic function (Gabor patch)
%
% Syntax:
%  [scene, p] = sceneHarmonic(scene, params, wave)
%
% Description:
%    Create a Gaussian windowed harmonic (Gabor patch). 
%    The spatial frequency specification is (cyces/image).  
%    To convert to cycles/deg, use cpd = freq/sceneGet(scene, 'fov');
%
%    To create colored images, you can add a background and signal spectral
%    power distribution to the harmonic parameters.  These can be
%    calculated using the humanConeIsolating function (See Example).
%
% Inputs:
%	 scene  - (Optional) A scene structure. Default is to call sceneInit.
%    params - (Optional) A structure containing the harmonic parameters.
%             Defaults are specifed by the function harmonicP. Some of the
%             possible parameters are:
%       name      - Used by oiSequence.visualize. Default 'harmonicP'.
%       ang       - Orientation (angle) of the grating. Default 0 degrees.
%       contrast  - Contrast. Default 1.
%       freq      - Spatial frequency (cycles/image). Default 1.
%       ph        - Phase (0 is center of image). Default pi/2.
%       row       - Rows. Default 64.
%       col       - Columns. Default 64.
%       GaborFlag - Gaussian window, standard deviation re: window size.
%                   Default 0.
%   wave    - (Optional)  Wavelength samples for scene. Default is pull a
%             default hyperspectral scene's wave.
%
% Optional key/value pairs:
%    None.
%
%
% Outputs:
%    scene  - The (created or) modified scene structure.
%    params - The harmonic parameters.
%
% See also
%   Use the examples from sceneCreate('harmonic'), which call this
%   function.

% History:
%    xx/xx/06       Imageval Consulting, LLC Copyright 2006
%    02/02/18  jnm  Formatting

% Example:
%{
% sceneHarmonic is called this way.
%
parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 128; parms.col = 128;
parms.GaborFlag=0;
[scene,parms] = sceneCreate('harmonic',parms);
%}


%% Build the spatial form of the image from harmonic parameters
if notDefined('params')
    params = harmonicP; 
    warning('Using default harmonic parameters'); 
end

% Image harmonics modulate around a value of 1.
img = imageHarmonic(params);

% To reduce rounding error problems for large dynamic range, we set the
% lowest value to something slightly more than zero.
img(img == 0) = 1e-4;
img = img / (2 * max(img(:)));  % Forces mean reflectance to 25% gray

%% Build scene from img data
if notDefined('scene'), scene = sceneInit; end
scene = sceneSet(scene, 'name', 'harmonic');
if notDefined('wave')
    scene = initDefaultSpectrum(scene, 'hyperspectral');
else
    scene = initDefaultSpectrum(scene, 'custom', wave);
end

nWave = sceneGet(scene, 'nwave');

% Mean illuminant at 100 cd.  This is really a dummy, or it could be the
% display white point.
wave = sceneGet(scene, 'wave');

if isfield(params, 'backSPD') && isfield(params, 'modSPD')
    % For a color image we modulate the signal spd by the img values, and
    % then add them into the background spd.
    
    il = illuminantCreate('equal photons', wave);
    % HACK.  Assumes back is 0.5, 0.5, 0.5
    % il = illuminantSet(il, 'energy', params.backSPD*2); 
    scene = sceneSet(scene, 'illuminant', il);
    
    % There may be a scaling issue for the max here.  Not sure now. (BW).
    contrast = img - mean(img(:));
    [r, c] = size(contrast);
    % Debugging.  Only background.
    % photons = repmat(params.backSPD(:)', [r * c, 1]);
    photons = contrast(:) * params.modSPD(:)' + ...
        repmat(params.backSPD(:)', [r * c, 1]);
    photons = XW2RGBFormat(photons, r, c);
else
    % No color described, so we simply make an equal photon illuminant spd
    % and treat the img values as a reflectance.
    il = illuminantCreate('equal photons', wave, 100);
    scene = sceneSet(scene, 'illuminant', il);
    photons = repmat(img, [1, 1, nWave]);
    [photons, r, c] = RGB2XWFormat(photons);
    illP = illuminantGet(il, 'photons');
    photons = photons * diag(illP);
    photons = XW2RGBFormat(photons, r, c);
end

scene = sceneSet(scene, 'photons', photons);

%% Set scene field of view and mean luminance
scene = sceneSet(scene, 'h fov', 1);
scene = sceneAdjustLuminance(scene, 100);

end