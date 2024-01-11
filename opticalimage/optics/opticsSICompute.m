function oi = opticsSICompute(scene,oi,aperture,varargin)
%Calculate OI irradiance using a custom shift-invariant PSF
%
%    oi = opticsSICompute(scene,oi,varargin)
%
% The shift invariant transform (OTF) is stored in the optics structure in
% the optics.data.OTF slot.  The representation includes the spatial
% frequencies in the x and y dimensions (OTF.fx, OTF.fy) which are
% represented in cycles/mm.  The value of the OTF, which can be complex, is
% stored in OTF.OTF.
%
% This routine simply manages the order of events for converting the scene
% radiance to sensor irradiance.  The events are:
%
%    * Converting scene radiance to image irradiance
%    * Applying the off-axis (e.g., cos4th) fall off
%    * The OTF is applied (opticsOTF)
%    * A final blur for the anti-aliasing filter is applied
%    * The illuminance is calculated and stored
%
% See also: opticsRayTrace, oiCompute, opticsOTF
%
% Example
%    scene = vcGetObject('scene');
%    oi    = vcGetObject('oi');
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('oi'), error('Opticalimage required.'); end
if ieNotDefined('aperture'), aperture = []; end
showWbar = ieSessionGet('waitbar');

if strcmp(oi.type,'wvf')
    wvf = oi;
    flength = wvfGet(wvf,'focal length','m');
    fnumber = wvfGet(wvf, 'f number');
    oi = oiCreate('shift invariant');
    oi = oiSet(oi,'f number',fnumber);
    oi = oiSet(oi,'optics focal length',flength);
else
    wvf = [];
end
% This is the default compute path
optics = oiGet(oi,'optics');

% Compute the basic parameters of the oi from the scene parameters.
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));
oi = oiSet(oi,'wave',sceneGet(scene,'wave'));

% We use the custom data.
% oi     = oiSet(oi,'optics',optics);

% Convert radiance units to optical image irradiance (photons/(s m^2 nm))
if showWbar
    wBar = waitbar(0,'OI-SI: Calculating irradiance...');
end

oi = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi));

%-------------------------------
% Distortion would go here. If we included it.
%-------------------------------

if showWbar, waitbar(0.3,wBar,'OI-SI Calculating off-axis falloff'); end

% Now apply the relative illumination (offaxis) fall-off
% We either apply a standard cos4th calculation, or we skip.
%waitbar(0.3,wBar,'OI-SI: Calculating off-axis falloff');
offaxismethod = opticsGet(optics,'offaxismethod');
switch lower(offaxismethod)
    case {'skip','none',''}
    case 'cos4th'
        oi = opticsCos4th(oi);
    otherwise
        fprintf('\n-----\nUnknown offaxis method: %s.\nUsing cos4th.',optics.offaxis);
        oi = opticsCos4th(oi);
end

if showWbar, waitbar(0.6,wBar,'OI-SI: Applying PSF'); end
% This section applys the OTF to the scene radiance data to create the
% irradiance data.
%
% If there is a depth plane in the scene, we also blur that and put the
% 'blurred' depth plane in the oi structure.
if showWbar, waitbar(0.6,wBar,'Applying PSF-SI'); end

% The original calculation
% oi = opticsOTF(oi,scene,varargin{:});

% We replace the old OTF based method with the version that goes
% through the wavefront terms developed for the flare calculation.
oi = opticsPSF(oi,scene,aperture,wvf,varargin{:});


switch lower(oiGet(oi,'diffuserMethod'))
    case 'blur'
        if showWbar, waitbar(0.75,wBar,'Diffuser'); end
        blur = oiGet(oi,'diffuserBlur','um');
        if ~isempty(blur), oi = oiDiffuser(oi,blur); end
    case 'birefringent'
        if showWbar, waitbar(0.75,wBar,'Birefringent Diffuser'); end
        oi = oiBirefringentDiffuser(oi);
    case 'skip'
        
end

% Compute image illuminance (in lux)
if showWbar, waitbar(0.9,wBar,'OI: Calculating illuminance'); end
oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

if showWbar, delete(wBar); end

end

