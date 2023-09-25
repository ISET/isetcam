function oi = oiCompute(oi,scene,opticsModel,varargin)
% Gateway routine for optical image irradiance calculation
%
% Syntax
%    oi = oiCompute(oi,scene,[opticsModel],varargin)
%
% Input
%   oi          - Optical image struct or a wavefront struct
%   scene       - Spectral scene struct
%   opticsModel - Optics model (skip, diffractionlimited,
%                 shiftinvariant, raytrace).  The default is the one
%                 in oiGet(oi,'optics model')
%
% Optional key/val
%   pad - How to pad the returned oi.  Options are zero, mean, crop,
%         spd (default: zero) 
%         (Don't tell everyone, but we could do a setprefs on this)
%
% Return
%   oi - The oi with the photon data 
%
% Brief description:
%
%  The spectral irradiance image, on the sensor plane just before sensor
%  capture, is the optical image.  This spectral irradiance distribution
%  depends on the scene and the the optics attached to the optical image
%  structure, oi.
%
%  The returned spectral radiance is padded compared to the scene to
%  allow for light spreading from the edge of the scene.  The amount
%  of padding is specified in oiApplyOTF, line 80, as
%
%   imSize   = oiGet(oi,'size');
%   padSize  = round(imSize/8); padSize(3) = 0;
%   sDist = sceneGet(scene,'distance');
%   oi = oiPad(oi,padSize,sDist);
%
%  To remove the padded region, you can use oiCrop, as in
%   oi = oiCrop(oi,'border');
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
oi = oiCompute(oi,scene,[],'pad','zero');
oiWindow(oi);
%}

%%
if ~exist('oi','var') || isempty(oi), error('Opticalimage required.'); end
if ~exist('scene','var') || isempty(scene), error('Scene required.'); end

if strcmp(oi.type,'wvf')
    % User sent in an wvf, not an oi.  We convert it to a shift invariant
    % oi here.  The oi is returned.
    oi = wvf2oi(oi);
end

% Ages ago, we had code that flipped the order of scene and oi.  We catch
% that case here and fix, issuing a warning.
if strcmp(oi.type,'scene') && strcmp(scene.type,'opticalimage')
    warning('flipping oi and scene variables.')
    tmp = scene; scene = oi; oi = tmp; clear tmp
end

% Default opticsModel.  The oi always has an optics slot.  I am not
% sure how we override and whether that makes sense.
if ~exist('opticsModel','var') || isempty(opticsModel)
    optics = oiGet(oi,'optics');
    opticsModel = opticsGet(optics,'model');
end

% Compute according to the selected model.  We pass along varargin
% because it may contain the key/val parameters such as pad.
opticsModel = ieParamFormat(opticsModel);
switch opticsModel
    case {'diffractionlimited','dlmtf', 'skip'}
        % The skip case is handled by the DL case
        oi = opticsDLCompute(scene,oi,varargin{:});
    case 'shiftinvariant'
        oi = opticsSICompute(scene,oi,varargin{:});
    case 'raytrace'
        oi = opticsRayTrace(scene,oi,varargin{:});
    otherwise
        error('Unknown optics model')
end

% Indicate scene it is derived from
oi = oiSet(oi,'name',sceneGet(scene,'name'));

% Pad the scene dpeth map and attach it to the oi.   The padded values are
% set to 0, though perhaps we should pad them with the mean distance.
oi = oiSet(oi,'depth map',oiPadDepthMap(scene,[],varargin{:}));

% We need to preserve metadata from the scene,
% But not overwrite oi.metadata if it exists
% We should probably rename this ieStructAppend
oi.metadata = appendStruct(oi.metadata, scene.metadata);

end