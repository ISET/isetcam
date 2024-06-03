function oi = oiCompute(oi,scene,varargin)
% Optical image irradiance calculation
%
% Syntax
%    oi = oiCompute(oi,scene,varargin)
%
% Brief
%   Convert a scene (radiance) into an optical image (irradiance) at
%   the sensor surface.  Uses the optics, which are often specified by
%   a wavefront structure.  The oi has a field, oi.optics, that
%   defines the optics parameters (including the wavefront).
%
% Input
%   oi          - Optical image struct or a wavefront struct
%   scene       - Spectral scene struct
%
% Optional key/val
%   'pad value' - The computation can pad the edges in various ways.
%       Options, implemented in oiPadValue called via opticsOTF 
%            zero - pad scene with zeros (Default)
%            mean - pad scene with mean image spectral radiance
%            border - pad with values from near the oi border
%            spd  - Use this vector as the SPD (NYI)
%
%   crop - Crop the OI to the same size as the scene. (Logical)
%          Default: false;
%
%   'pixel size' - Set the spatial sampling resolution of the oi image.
%                A scalar in meters. This parameter is convenient to
%                make the oi sampling match the sensor pixel size.
%
% Return
%   oi - The optical image with computed photon irradiance
%
% Description:
%  We call the image spectral irradiance on the sensor plane, just
%  before sensor capture, the ** optical image **.  This function
%  calculates the optical image from the scene and optics.
%
%  Compute methods
%  Two different compute methods are used.  These are determined by
%  the oi parameter, 'computeMethod', which specifies opticspsf or
%  opticsotf.
%
%  Scene padding
%  The user can pad the scene spectral radiance for the calculation in
%  several slightly different ways.
% 
%  In one case, the padding extends the scene with zeros. This allows
%  light to spread from the edge of the scene. In other cases, the
%  padding is set to the mean level of the scene, or the values near
%  the border. The padding is specified in by the optional key/value
%  argument 'pad', as in
%
%     oi = oiCompute(oi,scene,'pad value','mean');
%
%  To remove the padded region before routine, use this parameter
% 
%     oi = oiCompute(oi,scene,'crop',true);
%
%  or use oiCrop, as in oi = oiCrop(oi,'border');
%
% Optical models:
%
% Three types of optics are implemented.
%
% 'wvf': This model is a shift-invariant optics calculation. The
% optical PSF is specified by a wavefront aberration (wvf) structure.
% The wavefront parameters are explained and managed by
% wvfCreate/Set/Get/Compute. The basic principle is that the wavefront
% aberrations of the lens are defined by the coefficients of a Zernike
% polynomial.  The calculation from the wvf is carried out using
% either the computeMethod opticspsf (typical) or opticsotf
% (historical).
% 
% 'diffraction limited' - We implemented a diffraction-limited optics
% numerical calculation.  This is explained in opticsDLCompute. This
% blur and intensity in this computation depends on the diffraction
% limited parameters (f/#) but little else.
%
% The diffraction-limited model is a special case of the
% shift-invariant model. Specifying diffraction-limited implies using
% the specific wavelength-dependent OTFs that are determined by the
% f/#.
%
% 'ray trace' - A third model, ray trace, implements a
% **shift-varying** wavelength-dependent point spread functions. This
% model includes geometric distortion information, relative
% illumination and field-height and wavelength dependent point spread
% functions (or OTFS). The main use of this model these days is to
% import data from a ray trace program, such as Zemax. To set this
% method use opticsSet(optics,'model','rayTrace').
%
% In recent years, we use iset3d for ray trace calculations.
%
% In oiCreate you will see additional special cases.  These include
% 'human wvf' and 'human mw', special shift-invariant cases for
% computing the human optical image. The companion ISETBio repository
% has a more extensive set of tools for modeling biological vision.
%
% Use ieSessionSet('waitbar',0) to turn off waitbar displays
% Use ieSessionSet('waitbar',1) to turn on waitbar displays
%
% See also: 
%   oiCreate, wvfGet/Set, opticsDLCompute, opticsSICompute,
%   opticsRayTrace
%

% Examples:
%{
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene,'pad value','zero');
oiWindow(oi);
%}
%{
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene,'pad value','mean');
oiWindow(oi);
%}
%{
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene,'pad value','border','crop',true);
oiWindow(oi);
%}
%{
% Almost right.  Off by 1 part in 100.  Need to fix. (BW).
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene,'pad value','border','crop',true,'pixel size',1e-6);
oiWindow(oi);
%}
%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('oi',@isstruct);
p.addRequired('scene',@isstruct);
p.addParameter('padvalue','zero',@(x)(ischar(x) || isvector(x)));
p.addParameter('crop',false,@islogical);
p.addParameter('aperture',[],@ismatrix);
p.addParameter('pixelsize',[],@isscalar); % in meters
p.parse(oi,scene,varargin{:});

% Ages ago, we some code flipped the order of scene and oi.  We think
% we have caught all those cases, but we still test, and are now forcing
% the user to correct.
if strcmp(oi.type,'scene') && (strcmp(scene.type,'opticalimage') ||...
        strcmp(scene.type,'wvf'))
    error('You need to flip order oi and scene variables in the call to oiCompute')
    % We used to help the user
    % tmp = scene; scene = oi; oi = tmp; clear tmp
end

%% Adjust oi fov if user sends in a pixel size
if ~isempty(p.Results.pixelsize)

    % This is the pixel size in meters
    pz = p.Results.pixelsize;
    sw = sceneGet(scene, 'cols');
    flengthM = oiGet(oi, 'focal length', 'm');

    wAngular = atand(pz*sw/2/flengthM)*2;
    % oi uses scene hFOV later.
    scene = sceneSet(scene, 'wAngular',wAngular);
end

%% Compute according to the selected model.
%
% Should we pad the scene before the call to these computes?
%
% We pass varargin because it may contain the key/val parameters
% such as pad value and crop. But we only use pad value here.
if strcmp(oi.type,'wvf')
    opticsModel = 'shiftinvariant';
else
    opticsModel = oiGet(oi,'optics model');
end
switch ieParamFormat(opticsModel)
    case {'diffractionlimited','dlmtf', 'skip'}
        if strcmp(oi.type,'wvf')
            error('Wavefront is not supported for diffraction limited optics.');
        end
        % The skip case is handled by the DL case
        oi = opticsDLCompute(scene,oi,varargin{:});
    case 'shiftinvariant'
        oi = opticsSICompute(scene,oi,p.Results.aperture,varargin{:});
    case 'raytrace'
        % We are not using the pad value in this case.
        oi = opticsRayTrace(scene,oi,varargin{:});
    otherwise
        error('Unknown optics model')
end

% Indicate scene it is derived from
oi = oiSet(oi,'name',sceneGet(scene,'name'));

% Pad the scene dpeth map and attach it to the oi.   The padded values are
% set to 0, though perhaps we should pad them with the mean distance.
oi = oiSet(oi,'depth map',oiPadDepthMap(scene,[],varargin{:}));

% This crops the photons and the depth map
if p.Results.crop
    oi = oiCrop(oi,'border');
end

% Dangerous, introduced June 1, 2024 by BW.
if p.Results.pixelsize
    % The pixel size was not always precise.  I added this resample to
    % force the issue.  Not sure why it wasn't precise above.  Maybe
    % figuring out how to make that precise would be better.
    oi = oiSpatialResample(oi,p.Results.pixelsize,'m');
end

% We need to preserve metadata from the scene,
% But not overwrite oi.metadata if it exists
% We should probably rename this ieStructAppend
if (~isfield(oi,'metadata'))
    oi.metadata = struct;
end

% If the scene contains no metadata add an empty struct
if (~isfield(scene,'metadata'))
    scene.metadata = struct;
end
oi.metadata = appendStruct(oi.metadata, scene.metadata);

end