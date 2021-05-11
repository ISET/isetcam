function irradiance = oiCalculateIrradiance(scene, optics)
%Calculate optical image irradiance
%
%  irradiance = oiCalculateIrradiance(scene,oi)
%
%  The scene spectral radiance (photons/s/m2/sr/nm) is turned into optical
%  image irradiance (photons/s/m2/nm) based on information in the optics.
%  The formula for converting radiance to irradiance is
%
%     irradiance = pi /(1 + 4*fN^2*(1+abs(m))^2)*radiance;
%
%  where m is the magnification and fN is the f-number of the lens.
%  Frequently, in online references one sees the simpler formula:
%
%     irradiance = pi /(4*fN^2*(1+abs(m))^2)*radiance;
%
% (e.g., Gerald C. Holst, CCD Arrayas, Cameras and Displays, 2nd Edition,
% pp. 33-34 (1998))
%
%  This second formula is accurate for small angles, say when the sensor
%  sees only the paraxial rays.  The formula used here is more general and
%  includes the non-paraxial rays.
%
%  On the web one even finds simpler formulae, such as
%
%     irradiance = pi/(4*FN^2) * radiance
%
% For example, this formula is used in these online notes
%
%   http://www.ece.arizona.edu/~dial/ece425/notes7.pdf
%   http://www.coe.montana.edu/ee/jshaw/teaching/RSS_S04/Radiometry_geometry_RSS.pdf
%
%  Reference:
%    The formula is derived in Peter Catrysse's dissertation (pp. 150-151).
%    See also https://web.stanford.edu/class/ee392b/, course handouts
%    William L. Wolfe, Introduction to Radiometry, SPIE Press, 1998.
%
% Example:
%   scene = sceneCreate;  oi = oiCreate;
%   tic, irradiance = oiCalculateIrradiance(scene,oi); toc
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Historically, this was optics
%  We are planning to force this to always be an oi, but we are not yet
%  there.  So for now we allow oi or optics
if isequal(optics.type, 'opticalimage')
    % It is an oi, so get the optics from it
    optics = oiGet(optics, 'optics');
end
wave = sceneGet(scene, 'wave');

%% Scene data are in radiance units
radiance = sceneGet(scene, 'photons');

% oi = vcGetObject('oi');
model = opticsGet(optics, 'model');
model = ieParamFormat(model);
switch model
    case 'raytrace'
        % I am not sure we identify the ray trace case properly. If we are
        % in the ray trace case, we get the object distance from the ray
        % trace structure.
        fN = opticsGet(optics, 'rtEffectivefNumber');
        m = opticsGet(optics, 'rtmagnification');
    case {'skip'}
        m = opticsGet(optics, 'magnification'); % Always 1
        fN = opticsGet(optics, 'fNumber'); % What should this be?
    case {'diffractionlimited', 'shiftinvariant'}
        sDist = sceneGet(scene, 'distance');
        fN = opticsGet(optics, 'fNumber'); % What should this be?
        m = opticsGet(optics, 'magnification', sDist);
    otherwise
        error('Unknown optics model');
end

% Apply lens transmittance.
transmittance = opticsGet(optics, 'transmittance scale', wave);

% If transmittance is all 1's, we can skip this step
if any(transmittance(:) ~= 1)
    % Do this in a loop to avoid large memory demand
    transmittance = reshape(transmittance, [1, 1, length(transmittance)]);
    radiance = bsxfun(@times, radiance, transmittance);
end

% Apply the formula that converts scene radiance to optical image
% irradiance
irradiance = pi / (1 + 4 * fN^2 * (1 + abs(m))^2) * radiance;

end
