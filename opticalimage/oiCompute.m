function oi = oiCompute(oi,scene,opticsModel)
% Gateway routine for optical image irradiance calculation
%
% Syntax
%    oi = oiCompute(oi,scene,[opticsModel])
%
% Brief description:
%
% The spectral irradiance image, on the sensor plane just before sensor
% capture, is the optical image.  This spectral irradiance distribution
% depends on the scene and the the optics attached to the optical image
% structure, oi.
%
% The returned spectral radiance is padded compared to the scene to allow
% for light spreading from the edge of the scene.  The amount of padding is
% specified in oiApplyOTF, line 80, as
%
%   imSize   = oiGet(oi,'size');
%   padSize  = round(imSize/8); padSize(3) = 0;
%   sDist = sceneGet(scene,'distance');
%   oi = oiPad(oi,padSize,sDist);
%
% To remove the padded region, you can use oiCrop.
%
% Optical models:
%
% Three types of optical calculations are implemented .  These are selected
% from the interface in the oiWindow, or they can be set via
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
% * Historically, we also used a third model is a full ray trace model that
% allows shift-varying wavelength-dependent point spread functions.  This
% model includes geometric distortion information, relative illumination
% and field-height and wavelength dependent point spread functions (or
% OTFS). These are usually imported from a full ray trace program, such as
% Zemax.  They can also be obtained by the companion CISET program. To set
% this method use opticsSet(optics,'model','rayTrace')
%
% BUT IN RECENT YEARS, we are using iset3d for ray tracing calculations.
% That method is greatly preferred, and we imagine that rayTrace mode here
% will be deprecated.
%
% Use ieSessionSet('waitbar',0) to turn off waitbar displays
% Use ieSessionSet('waitbar',1) to turn on waitbar displays
%
% Example
%   oi = oiCompute(scene,oi);
%
%   oi = vcGetObject('oi'); scene = vcGetObject('scene');
%   load siZemaxExample00
%   optics = opticsSet(optics,'model','shiftinvariant');
%   oi = oiSet(oi,'optics',optics);
%   oi = oiCompute(scene,oi);
%
% Copyright ImagEval Consultants, LLC, 2005
%
% See also: 
%   opticsDLCompute, opticsSICompute, opticsRayTrace
%

% Note about cropping the oi data back to the same size (no black border)
% on the scene window
%
% The optical image is padded by 1/8th of the scene size on all sides.
% So the eliminate the black border, we need to crop a rect that is
%
%  rect = [row col height width]
%  oiSize = sceneSize * (1 + 1/4))
%  sceneSize = oiGet(oi,'size')/(1.25);
%
%  [sceneSize(1)/8 sceneSize(2)/8 sceneSize(1) sceneSize(2)]
%

if ~exist('oi','var') || isempty(oi), error('Opticalimage required.'); end
if ~exist('scene','var') || isempty(scene), error('Scene required.'); end

if strcmp(oi.type,'wvf')
    % User sent in an wvf, not an oi.  We convert it to an oi here
    % assuming it is in the diffraction limited domain.
    %
    % This edit, which seems right to BW, breaks the flare
    % calculation.
    %
    % oi = wvf2oi(oi,'model','diffraction limited');
    %
    oi = wvf2oi(oi);
end

% Ages ago, we had code that flipped the order of scene and oi.  We catch
% that here.
if strcmp(oi.type,'scene') && strcmp(scene.type,'opticalimage')
    warning('flipping oi and scene variables.')
    tmp = scene; scene = oi; oi = tmp; clear tmp
end

if ~exist('opticsModel','var') || isempty(opticsModel)
    optics = oiGet(oi,'optics');
    opticsModel = opticsGet(optics,'model');
end

% Compute according to the selected model
opticsModel = ieParamFormat(opticsModel);
switch opticsModel
    case {'diffractionlimited','dlmtf', 'skip'}
        % The skip case is handled by the DL case
        oi = opticsDLCompute(scene,oi);
    case 'shiftinvariant'
        oi = opticsSICompute(scene,oi);
    case 'raytrace'
        oi = opticsRayTrace(scene,oi);
    otherwise
        error('Unknown optics model')
end

% Indicate scene it is derived from
oi = oiSet(oi,'name',sceneGet(scene,'name'));

% Pad the scene dpeth map and attach it to the oi.   The padded values are
% set to 0, though perhaps we should pad them with the mean distance.
oi = oiSet(oi,'depth map',oiPadDepthMap(scene));

% We need to preserve metadata from the scene,
% But not overwrite oi.metadata if it exists
oi.metadata = appendStruct(oi.metadata, scene.metadata);

end