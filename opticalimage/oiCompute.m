function oi = oiCompute(oi,scene,varargin)
% Gateway routine for optical image irradiance calculation
%
% Syntax
%    oi = oiCompute(oi,scene,varargin)
%
% Input
%   oi          - Optical image struct or a wavefront struct
%   scene       - Spectral scene struct
%
% Optional key/val
%   pad value - Pad value oi.  
%       Options, implemented in oiPadValue called via opticsOTF 
%            zero - pad scene with zeros (Default)
%            mean - pad scene with mean image spectral radiance
%            border - pad with values from near the border
%            spd  - Use this vector as the SPD (NYI)
%
%   crop - Crop the OI to the same size as the scene. (Logical)
%          Default: false;
%         (We could do a setprefs on these, but BW is resistant.)
%
% Return
%   oi - The oi with computed photon irradiance
%
% Brief description:
%  We call the spectral irradiance image, on the sensor plane just
%  before sensor capture, the ** optical image **.  This spectral
%  irradiance depends on the scene and the the optics attached to the
%  optical image structure, oi.
%
%  The returned spectral radiance is padded compared to the scene to
%  allow for light spreading from the edge of the scene.  The nature
%  of the padding is specified in by the optional key/value argument
%  'pad'.  The default padding call is something like this:
%
%    imSize   = oiGet(oi,'size');
%    padSize  = round(imSize/8); padSize(3) = 0;
%    sDist = sceneGet(scene,'distance');
%    oi = oiPad(oi,padSize,sDist);
%
%  To remove the padded region, you can use oiCrop, as in
%
%     oi = oiCrop(oi,'border');
%
% Optical models:
%
% Three types of optical calculations are implemented.  These are
% selected from the interface in the oiWindow, or they can be set via
%
%    optics = opticsSet(optics,'model', parameter)
%
% This function calls the relevant model depending on the setting in
% opticsGet(optics,'model');
%
% * The first model is based on diffraction-limited optics and calculated
% in opticsDLCompute. This blur and intensity in this computation depends
% on the diffraction limited parameters (f/#) but little else.
%
% To create an image with no blur, set the f/# to a very small number.
% This will provide an image that has the geometry and zero-blur as used in
% computer graphics pinhole cameras.  The absolute light level, however,
% will be higher than what would be seen through a small pinhole. You can
% manage this by setting scaling the spectral irradiance
% (oiAdjustIlluminance).
%
% * The second model is shift-invariant optics.  This depends on having a
% wavelength-dependent OTF defined and included in the optics structure.
% Examples of shift-invariant data structres can be found in the
% data\optics directory. More generally, the OTF can be calculated using
% the wavefront tools (wvf<TAB>) that allow the user to specify wavefront
% aberrations using the Zernike Polynomial basis. In this case, the optical
% image is computed using the function opticsSICompute.  To use this method
% use opticsSet(optics,'model','shiftInvariant');
%
% N.B. The diffraction-limited model is a special case of the
% shift-invariant model. Specifying diffraction-limited implies using the
% specific wavelength-dependent OTFs that are determined by the f/#.
%
% ISET also includes a special shift-invariant case for computing the human
% optical image. You may specify the optics model to be 'human'.  In that
% case, this program calls the routine humanOI, which uses the human OTF
% calculations in a shift-invariant fashion.  The companion ISETBIO program
% has a more extensive set of tools for modeling biological vision.  That
% program was derived from ISET, but it is not as extensive and does not
% include the full set of models.
%
% * Historically, we used a third model, ray trace, to
% allow **shift-varying** wavelength-dependent point spread functions.
% This model includes geometric distortion information, relative
% illumination and field-height and wavelength dependent point spread
% functions (or OTFS). The main use of this model these days is to
% import data from a ray trace program, such as Zemax. To set this
% method use opticsSet(optics,'model','rayTrace').
%
% Note:  IN RECENT YEARS, we use iset3d for ray trace calculations.
%
% Use ieSessionSet('waitbar',0) to turn off waitbar displays
% Use ieSessionSet('waitbar',1) to turn on waitbar displays
%
% Example
%   oi = oiCompute(scene,oi);
%
%   oi = ieGetObject('oi'); scene = vcGetObject('scene');
%   load siZemaxExample00
%   optics = opticsSet(optics,'model','shiftinvariant');
%   oi = oiSet(oi,'optics',optics);
%   oi = oiCompute(scene,oi);
%
% See also: 
%   opticsDLCompute, opticsSICompute, opticsRayTrace
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
%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('oi',@isstruct);
p.addRequired('scene',@isstruct);
p.addParameter('padvalue','zero',@(x)(ischar(x) || isvector(x)));
p.addParameter('crop',false,@islogical);
p.parse(oi,scene,varargin{:});

% if ~exist('oi','var') || isempty(oi), error('Opticalimage required.'); end
% if ~exist('scene','var') || isempty(scene), error('Scene required.'); end

if strcmp(oi.type,'wvf')
    % User sent in an wvf, not an oi.  We convert it to a shift invariant
    % oi here.  The oi is returned.
    oi = wvf2oi(oi);
end

% Ages ago, we some code flipped the order of scene and oi.  We think
% we have caught all those cases, but we still test.  Maybe delete
% this code by January 2024.
if strcmp(oi.type,'scene') && strcmp(scene.type,'opticalimage')
    warning('flipping oi and scene variables.')
    tmp = scene; scene = oi; oi = tmp; clear tmp
end

%% Compute according to the selected model.

% Should we pad the scene before the call to these computes?

% We pass varargin because it may contain the key/val parameters
% such as pad value and crop. But we only use pad value here.
opticsModel = oiGet(oi,'optics model');
switch ieParamFormat(opticsModel)
    case {'diffractionlimited','dlmtf', 'skip'}
        % The skip case is handled by the DL case
        oi = opticsDLCompute(scene,oi,varargin{:});
    case 'shiftinvariant'
        oi = opticsSICompute(scene,oi,varargin{:});
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

% We need to preserve metadata from the scene,
% But not overwrite oi.metadata if it exists
% We should probably rename this ieStructAppend
if (~isfield(oi,'metadata'))
    oi.metadata = struct;
end
oi.metadata = appendStruct(oi.metadata, scene.metadata);

end