function oi = opticsSICompute(scene,oiwvf,aperture,varargin)
% Calculate OI irradiance using a shift-invariant PSF
%
%    oi = opticsSICompute(scene,oiwvf,varargin)
%
% The shift invariant transform is calculated from the optics
% structure. At present, we compute the PSF from a stored wavefront
% function, on the fly, using the sampling density appropriate for the
% scene.  This is done in the opticsPSF() function.  
% 
% (See below for another option, opticsOTF().)
% 
% This routine simply manages the order of events for converting the scene
% radiance to sensor irradiance.  The events are:
%
%    * Converting scene radiance to image irradiance
%    * Applying the off-axis (e.g., cos4th) fall off
%    * The OTF is applied 
%         (opticsPSF or opticsOTF, according to the optics name field)
%    * A final blur for the anti-aliasing filter is applied
%    * The illuminance is calculated and stored
%
% Note:
%
%  Historically, we pre-computed an OTF and stored it in the optics
%  structure in the optics.data.OTF slot.  This contines the values
%
%    OTF.OTF, OTF.fx, OTF.fy (where frequency is cycles/mm)
%
%  We interpolate the stored OTF to match the sampling density in the
%  scene.  This is the opticsOTF() function.  To use this path rather
%  than the opticsPSF, set the name field of the optics structure to
%  'opticsotf'.  For an example, see v_icam_oiPad
%
% See also: 
%   opticsRayTrace, oiCompute, opticsPSF, opticsOTF

%%
if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('oiwvf'), error('Opticalimage or wvf required.'); end
if ieNotDefined('aperture'), aperture = []; end
showWbar = ieSessionGet('waitbar');

% Interpret the oiwvf as an oi or wvf.  If an oi, it might have a wvf.
if strcmp(oiwvf.type,'wvf')
    % User sent in a wvf
    wvf = oiwvf;
    flength = wvfGet(wvf,'focal length','m');
    fnumber = wvfGet(wvf, 'f number');
    oi = oiCreate('shift invariant');
    oi = oiSet(oi,'f number',fnumber);
    oi = oiSet(oi,'optics focal length',flength);
elseif strcmp(oiwvf.type,'opticalimage')
    % User sent an OI.  It might have a wvf in the optics
    oi = oiwvf;
    optics = oiGet(oi,'optics');
    if isfield(optics,'wvf')
        wvf = optics.wvf;
    else
        wvf = [];
    end
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

% The optics calculation
computeMethod = oiGet(oi,'compute method');
switch lower(computeMethod)
    case {'humanmw','opticsotf'}
        % We did not update the MW calculation.  It was very rough
        % anyway.  We use the old methods to calculate.
        oi = opticsOTF(oi,scene,varargin{:});
    otherwise
        % We replaced the old OTF based method with the version that
        % goes through the wavefront terms, as developed for the flare
        % calculation.
        oi = opticsPSF(oi,scene,aperture,wvf,varargin{:});
end

% Diffuser
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

