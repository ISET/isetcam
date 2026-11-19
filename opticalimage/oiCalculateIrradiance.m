function irradiance = oiCalculateIrradiance(scene,optics)
%Calculate optical image irradiance from scene radiance
%
% Synopsis
%   irradiance = oiCalculateIrradiance(scene,oi)
%   irradiance = oiCalculateIrradiance(scene,optics)
%
% Brief description
%   Converts the scene spectral radiance (photons/s/m2/sr/nm) into the
%   on-axis spectral irradiance (photons/s/m2/nm) at the image plane,
%
%     irradiance = pi * T * radiance / (m^2 + 4*N^2*(1 + |m|)^2)
%
%   where N is the f-number (focal length / entrance pupil diameter), m is
%   the magnification (negative for an inverted image), and T is the lens
%   transmittance.  The irradiance is capped at pi * T * radiance, the
%   physical maximum.  Ray-trace optics use their working f-number
%   directly (see Description).
%
% Inputs
%   scene:  ISETCam scene
%   optics: optical image or optics structure
%
% Returns
%   irradiance: row x col x wave irradiance (photons/s/m2/nm), the same
%               size as the scene photons.  Off-axis falloff (e.g., cos4th)
%               and blur are applied later by the optics compute functions.
%
% Description
%   Derivation.  The formula follows from conservation of energy.  A scene
%   patch of area A_s at distance d_o, with radiance L, sends power
%
%     P = L * A_s * pi * sin(alpha)^2,   sin(alpha)^2 = a^2/(a^2 + d_o^2)
%
%   into an entrance pupil of radius a = f/(2N).  The lens images the patch
%   onto an area A_i = m^2 * A_s at the image distance d_i = f*(1 + |m|),
%   with |m| = d_i/d_o (lensmaker's equation).  The irradiance is the power
%   per unit image area, E = P/A_i.  Substituting d_o = d_i/|m| gives the
%   formula above.  It assumes a Lambertian scene, equal entrance and exit
%   pupils (pupil magnification 1), air on both sides, and no losses other
%   than T.
%
%   Magnification term (Issue #22).  The factor (1 + |m|) is required.
%   N*(1 + |m|) is the working f-number: when the object is near, the image
%   forms farther from the lens than f, so the cone of light reaching each
%   image point is narrower.  The common textbook form
%
%     irradiance = pi * radiance / (4*N^2)
%
%   is the special case of an object at infinity (m = 0).  ISETCam places
%   the optical image at d_i (oiGet(oi,'width') is 2*d_i*tan(fov/2)), so
%   removing the factor would put (1 + |m|)^2 more power on the image than
%   enters the lens: 4x at 1:1 magnification, and about 3% for the human
%   eye viewing an object at 1.2 m.
%
%   Cameras and eyes.  ISETCam models a camera, which focuses by moving the
%   image plane: the focal length f is fixed and the image distance is
%   d_i = f*(1 + |m|).  An eye focuses by accommodation: the image
%   distance (the eye length) is fixed and the focal length shortens.
%   Formulas that use the eye length, such as L*pupilArea/eyeLength^2,
%   therefore have no magnification factor.  To model an eye of length
%   d_eye focused on an object at distance d_o, set the focal length to
%   1/(1/d_eye + 1/d_o).  Then d_i = d_eye, and this function and the
%   eye-length formula agree.
%
%   The m^2 term (changed November 2026, Issues #22 and #23).  Earlier
%   versions used 1 in place of m^2,
%
%     irradiance = pi * radiance / (1 + 4*N^2*(1 + |m|)^2)
%
%   which is the solid angle of a flat disk of diameter f/N seen from the
%   image point at distance d_i.  A real, aberration-corrected lens does
%   not form its image cone that way, and that form loses a fraction
%   (1 - m^2)/(1 + 4*N^2*(1+|m|)^2) of the photons that enter the lens
%   (1.5% at f/4, 4% for a 7 mm human pupil).  It also made the
%   irradiance grow more slowly than the pupil area.  With m^2, the
%   irradiance from a distant object scales with the pupil area, as
%   conservation of energy requires.  The two forms agree at unit
%   magnification, so the 'skip' model (m = -1) is unchanged.  For most
%   cameras m^2 is negligible and the formula is effectively
%   pi*radiance/(4*N^2*(1 + |m|)^2).
%
%   Physical limit.  No passive lens in air can deliver more than
%   pi*radiance; that requires the cone of light reaching the image to
%   fill a hemisphere, which is a working f-number of 0.5.  Smaller
%   working f-numbers cannot be built, and for them the formula would
%   exceed the limit, so the irradiance is capped at pi*T*radiance.
%   oiCreate('pinhole') sets f/0.001 to suppress diffraction blur.  With
%   diffraction-limited optics it therefore receives the capped value.
%
%   Ray-trace optics.  The ray-trace effective f-number is the working
%   f-number, N_w = 1/(2*sin(theta')), that the Zemax export macro
%   (ISET_RT_ZEMAX.ZPL) computes from the real marginal ray at the lens's
%   object distance.  It already includes the effect of magnification and
%   pupil magnification, so for ray-trace optics
%
%     irradiance = pi * T * radiance / (4*N_w^2)
%
%   with no further magnification factor (also capped at pi*T*radiance).
%   Before November 2026 the (1 + |m|) factor was applied on top of N_w,
%   counting the magnification twice.
%
% References
%   G. C. Holst, CCD Arrays, Cameras and Displays, 2nd ed., pp. 33-34
%   (1998): image irradiance with the (1 + |m|) factor.
%   Working f-number: https://en.wikipedia.org/wiki/F-number
%   Peter Catrysse's dissertation, pp. 150-151: the earlier flat-disk
%   formula.
%
% See also
%   oiCompute, opticsDLCompute, opticsSICompute, opticsGet

% Examples:
%{
scene = sceneCreate;
oi = oiCreate;
irradiance = oiCalculateIrradiance(scene,oi);
%}
%{
% Irradiance from a distant object scales with the pupil area
scene = sceneCreate('uniform ee',8);
oi = oiCreate('diffraction limited');
oi = oiSet(oi,'optics focal length',0.017);
oi = oiSet(oi,'optics fnumber',17/2); E2 = oiCalculateIrradiance(scene,oi);
oi = oiSet(oi,'optics fnumber',17/7); E7 = oiCalculateIrradiance(scene,oi);
E7(1)/E2(1)    % close to (7/2)^2 = 12.25
%}

%% Historically, this was optics
%  We are planning to force this to always be an oi, but we are not yet
%  there.  So for now we allow oi or optics
if isequal(optics.type,'opticalimage')
    % It is an oi, so get the optics from it
    optics = oiGet(optics,'optics');
end
wave = sceneGet(scene,'wave');

%% Scene data are in radiance units
radiance = sceneGet(scene, 'photons');

model = opticsGet(optics, 'model');
model = ieParamFormat(model);
switch model
    case 'raytrace'
        % The ray-trace effective f-number is the working f-number from
        % the real marginal ray at the lens's object distance.  It already
        % includes the magnification (see Description).
        fNWorking = opticsGet(optics, 'rtEffectivefNumber');
        denom = 4*fNWorking^2;
    case {'skip'}
        m  = opticsGet(optics, 'magnification');  % Always -1
        fN = opticsGet(optics, 'fNumber');
        denom = m^2 + 4*fN^2*(1 + abs(m))^2;
    case {'diffractionlimited', 'shiftinvariant'}
        sDist = sceneGet(scene, 'distance');
        fN    = opticsGet(optics, 'fNumber');
        m     = opticsGet(optics, 'magnification', sDist);
        denom = m^2 + 4*fN^2*(1 + abs(m))^2;
    otherwise
        error('Unknown optics model');
end

% Apply lens transmittance.
transmittance = opticsGet(optics,'transmittance scale',wave);

% If transmittance is all 1's, we can skip this step
if any(transmittance(:) ~= 1)
    transmittance = reshape(transmittance, [1 1 length(transmittance)]);
    radiance = bsxfun(@times, radiance, transmittance);
end

%% Convert scene radiance to image irradiance (see Description)
% Working f-numbers below 0.5 cannot be built; cap at pi*radiance.
irradiance = pi * min(1, 1/denom) * radiance;

end
