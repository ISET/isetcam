function scene = sceneIlluminantScale(scene)
% Set the illuminant level to be consistent with reflectance data
%
%    scene = sceneIlluminantScale(scene)
%
% The illuminant level in photons should be consistent with surface
% reflectance levels of objects in the scene.  This routine sets the level.
% We use this as a rough approximation because in many cases we don't know
% the true illuminant everywhere.
%
% Here, we assign an illuminant radiance level so that in general the
% formula
%
%      sceneRadiance / illuminantRadiance
%
% is a reasonable reflectance, where reasonable means 0,1 and where any
% known reflectance point is correct.  If there is a known reflectance in
% the scene at a point (sceneGet(scene,'knownReflectance')), then we try to
% set the scale to make that known point consistent.
%
% If there is no information about a known reflectance, we find the peak
% radiance in the scene and assume that its level is 0.9 reflectance.
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2010.

if ieNotDefined('scene'), scene = vcGetObject('scene'); end

illuminantSPD = sceneGet(scene,'illuminant photons');
if isempty(illuminantSPD), error('Scene requires an illuminant'); end

wave = sceneGet(scene,'wave');

v  = sceneGet(scene,'known reflectance'); % Returns ref,row,col,wave index
if isempty(v)
    % Find the peak radiance and wavelength.  Assume that the reflectance
    % there is 0.9. Or 1. Why not.
    v = sceneGet(scene,'peak radiance and wave');
    idxWave = find(wave == v(2));
    p = sceneGet(scene,'photons',v(2));
    [tmp, ij] = max2(p);
    v = [0.9 ij(1) ij(2) idxWave];
    scene = sceneSet(scene,'knownReflectance',v);
end

reflectance = v(1); thisWave = wave(v(4));
photon = sceneGet(scene,'photons',thisWave);
sceneRadiance = photon(v(2),v(3));

% When we divide the sceneRadiance by the illuminant, we should get the
% reflectance.  This will be 1 if everything is fine.  Otherwise it is
% the scale factor we use to multiply the illuminant
s = (sceneRadiance/reflectance)/illuminantSPD(v(4));
scene = sceneSet(scene,'illuminantPhotons',s*illuminantSPD);

return;
