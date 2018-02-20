function scene = sceneCreateMacbeth(surface,lightSource,scene)
% Create a hyperspectral scene of the Macbeth chart.
%   
%   scene = sceneCreateMacbeth(surface,lightSource,[scene])
%
% The surface reflectances and light source are specified as arguments.
% The color signal is computed (in photons); these values are then
% attached to the scene structure.
%
% Used by the sceneWindow callbacks to create the Macbeth images.
%
% Copyright ImagEval Consultants, LLC, 2005.

if ~checkfields(lightSource,'spectrum'), error('Bad light source description.');
elseif ~checkfields(surface,'spectrum'), error('Bad surface description.');
elseif ~isequal(lightSource.spectrum.wave(:),surface.spectrum.wave(:))
    error('Mis-match between light source and object spectral fields')
end

% Illuminant photons
iPhotons      = illuminantGet(lightSource,'photons');

% Surface in XW format
[surface,r,c] = RGB2XWFormat(surface.data);

% Multiply for radiance and then put back in RGB format
sPhotons      = surface*diag(iPhotons);
sPhotons      = XW2RGBFormat(sPhotons,r,c);

% Set the scene photons and light source
scene = sceneSet(scene,'photons',sPhotons);
scene = sceneSet(scene,'illuminant',lightSource);

return;
