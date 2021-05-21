function scene = sceneAdjustReflectance(scene,newR)
% Adjust the reflectance, keeping the illuminant unchanged, for a scene
%
% Synopsis
%    scene = sceneAdjustReflectance(scene,newR)
%
% Inputs:
%   scene:  A scene (ISETCam scene struct)
%   newR:   The new reflectance (1D, or row x col x wave) of the scene
%           reflectance
%
% Returns
%  scene:  The modified scene
%
% Description:
%   Each scene radiance can be decomposed into the illumination data and
%   the reflectance data.  We do that decomposition first, we replace the
%   reflectance data with the new reflectance data (newR) and recompute and
%   return the new scene radiance.
%
%   In the general case, we replace the scene reflectances, point by point,
%   with the reflectances in the row x col x wave newR.
%
%   As a special case, when the scene is uniform, newR can be a reflectance
%   vector that is used at every point in the scene.
%
% See also:
%  sceneAdjustIlluminant, sceneAdjustLuminance
%

% Examples:
%{
  scene = sceneCreate('uniform ee');
  wave = sceneGet(scene,'wave');
  fName  = fullfile(oreyeRootPath,'data','tongue','meanReflectance');
  tongue = ieReadSpectra(fName,wave);
  scene = sceneAdjustReflectance(scene,tongue);
%}
%{
  % We should test sceneAdjustReflectance more
%}

%% Parameters
if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('newR'), error('RGB format reflectance required'); end

% Check that newR is a reflectance
assert(max(newR(:)) <= 1.0);
assert(min(newR(:)) >= 0.0);

wave = sceneGet(scene,'wave');

illFormat  = sceneGet(scene,'illuminant format');
illPhotons = sceneGet(scene,'illuminant photons');
if isvector(newR)
    % This is the uniform scene case
    if ~(length(wave) == length(newR))
        error('newR does not match the scene wavelength');
    end
    
    switch illFormat
        case 'spectral'
            sz = sceneGet(scene,'size');
            photons = newR .* illPhotons;
            photons = repmat(photons(:),1,sz(1),sz(2));
            photons = permute(photons,[2,3,1]);
        case 'spatial spectral'
            warning('Illuminant is spatial-spectral; reflectance is a vector.\n');
            % Get spatial-spectral illuminant and reformat
            [photons,row,col] = RGB2XWFormat(illPhotons);
            
            % Multiply by the one reflectance.  The result is a map of the
            % illuminant, really.
            photons = photons*diag(newR);
            
            % Put the photons back in shape
            photons = XW2RGBFormat(photons,row,col);
            
        otherwise
            error('Unknown illuminant format %s\n',illFormat);
    end
    
elseif ndims(newR) == 3
    if ~(length(wave) == size(newR,3))
        error('newR does not match the scene wavelength');
    end
    
    switch illFormat
        case 'spectral'
            % Format, multiply and reformat
            [newR,row,col] = RGB2XWFormat(newR);
            
            % Need to allow for the spatial-spectral case
            photons        = newR*diag(illPhotons);
            
            photons        = XW2RGBFormat(photons,row,col);
            
        case 'spatial spectral'
            photons = illPhotons .* newR;
            
        otherwise
            error('Unknown illuminant format %s\n',illFormat);
    end
    
    
end

% Replace the photons.
scene = sceneSet(scene,'photons',photons);

end

