function oi = humanOI(scene, oi)
% Calculate human optical retinal irradiance from scene description
%
%    oi = humanOI(scene,oi)
%
% We calculate the spectral irradiance image on the retinal image.  This is
% the image just before sensor capture.  This spectral
% irradiance distribution depends on the scene and the the human optics.
%
% Example
%   oi = humanOI(scene,oi)
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('oi'), error('Opticalimage required.'); end
showWaitbar = ieSessionGet('waitbar');

% This is the default compute path
optics = oiGet(oi, 'optics');

% We are here to do the human calculation
optics = opticsSet(optics, 'otfmethod', 'human');

% Compute the basic parameters of the oi from the scene parameters.
oi = oiSet(oi, 'wangular', sceneGet(scene, 'wangular'));
oi = oiSet(oi, 'spectrum', sceneGet(scene, 'spectrum'));

%  There really shouldn't be both.  Not sure what to do at this point.  If
%  this is the only time we ever set the optics spectrum, then we have
%  enforced the equality.  But just by having the variable, people can
%  create an inconsistency.  Think.
optics = opticsSet(optics, 'spectrum', oiGet(oi, 'spectrum'));
oi = oiSet(oi, 'optics', optics);

% Calculate the irradiance of the optical image in photons/(s m^2 nm)
if showWaitbar, wBar = waitbar(0, 'OI: Calculating irradiance...'); end
oi = oiSet(oi, 'photons', oiCalculateIrradiance(scene, oi));

% Here, we need insert a distortion function, and a button on the window
% that let us indicate that we want the distortion computed.  Which
% point in the computation should have the distortion?  Before or after
% application of the OTF?
%
if showWaitbar, waitbar(0.3, wBar, 'OI: Calculating off-axis falloff'); end

% Now apply the offaxis fall-off
% We either apply a standard cos4th calculation, or we use the more
% elaborate relative illumination derived from CodeV.
% stored inside of data\optics\Lens Design\Standard.
oi = opticsCos4th(oi);

% Apply the human MTF here.
% waitbar(0.6,wBar,'OI: Applying OTF');
oi = opticsOTF(oi);

% Compute image illuminance (in lux)
if showWaitbar, waitbar(0.9, wBar, 'OI: Calculating illuminance'); end

oi = oiSet(oi, 'illuminance', oiCalculateIlluminance(oi));

if showWaitbar, close(wBar); end

return;
