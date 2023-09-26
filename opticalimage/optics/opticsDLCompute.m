function oi = opticsDLCompute(scene,oi,varargin)
%Diffraction limited optical image computation
%
%   oi = opticsDLCompute(scene,oi,varargin)
%
% Input
%   scene
%   oi
%
% Optional key/val
%
% Return
%   oi
%
% The diffraction limited optical image calculation uses only a few
% parameters (f-number, focal length) to calculate the optical image.  The
% diffraction limited OTF is calculated on the fly in dlMTF, and applied to
% the scene image in this routine.
%
% See also:  
%   oiCompute, opticsSICompute, opticsRayTrace

% TODO:  We should insert a geometric distortion function in this code,
% rather than using it only in the ray trace methods.

%%
if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('oi'),    oi = vcGetObject('oi');       end
showWaitBar = ieSessionGet('waitbar');

optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
opticsModel = ieParamFormat(opticsModel);
if ~(strcmpi(opticsModel,'dlmtf') || ...
        strcmpi(opticsModel,'diffractionlimited') ||...
        strcmpi(opticsModel, 'skip'))
    error('Bad DL optics model %s',opticsModel);
else
    if showWaitBar, wStr = 'OI-DL: '; end
end

% Compute the basic parameters of the oi from the scene parameters.
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));
oi = oiSet(oi,'wave',sceneGet(scene,'wave'));

oi = oiSet(oi,'optics otf wave',sceneGet(scene,'wave'));

% optics = opticsSet(optics,'spectrum',oiGet(oi,'spectrum'));
% oi     = oiSet(oi,'optics',optics);

% Calculate the irradiance of the optical image in photons/(s m^2 nm)

if showWaitBar, wBar = waitbar(0,[wStr,' Calculating irradiance...']); end
oi   = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi));
% ieAddObject(oi); oiWindow;

% We could insert a distortion function at this point.
if showWaitBar, waitbar(0.3,wBar,[wStr,' Calculating off-axis falloff']); end

% Now apply the offaxis fall-off.
% We either apply a standard cos4th calculation, or we use the more
% elaborate relative illumination derived from CodeV. stored inside of
% data\optics\Lens Design\Standard.
offaxismethod = opticsGet(optics,'off axis method');
switch lower(offaxismethod)
    case {'skip','none',''}
    case 'cos4th'
        oi = opticsCos4th(oi);
    otherwise
        fprintf('\n-----\nUnknown offaxis method: %s.\nUsing cos4th.',optics.offaxis);
        oi = opticsCos4th(oi);
end

% Compute and apply the diffraction-limited MTF, or possibly skip.  We come
% through here on the 'skip' condition because we want to apply all of the
% other imperfections in that case (cos4th, and so forth).
%
% In the DL case, we allow for defocus. The defocus is useful for
% characterizing the effect outside of the focal plane and hence, the depth
% of field.
if showWaitBar, waitbar(0.6,wBar,[wStr,' Applying OTF']); end
oi = opticsOTF(oi,scene,varargin{:});

% Diffuser and illuminance, or just illuminance.  Diffuser always resets
% the illuminance, which seems proper.
switch lower(oiGet(oi,'diffuser method'))
    case 'blur'
        if showWaitBar, waitbar(0.75,wBar,[wStr,' Diffuser']); end
        blur = oiGet(oi,'diffuserBlur','um');
        if ~isempty(blur), oi = oiDiffuser(oi,blur); end
    case 'birefringent'
        if showWaitBar, waitbar(0.75,wBar,[wStr,' Birefringent Diffuser']); end
        oi = oiBirefringentDiffuser(oi);
    case 'skip'
    otherwise
        error('unknown diffuser method %s\n',oiGet(oi,'diffuser method'));
end

% Compute image illuminance (in lux)
% waitbar(0.9,wBar,[wStr,' Calculating illuminance']);
oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

if showWaitBar, close(wBar); end

end
