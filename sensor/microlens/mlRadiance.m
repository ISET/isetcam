function [ml, psImage] = mlRadiance(ml, sensor, mlFlag)
% Main microlens computational routine
%
%    [ml, psImage] = mlRadiance([microLens],[sensor],[mlFlag = 1])
%
% This routine is invoked for computing the radiance distribution of the
% microlens at a single pixel. Data about the source and pixel are all
% contained in the microlens structure.
%
% Inputs
%  ml:      Microlens structure
%  sensor:  ISET sensor
%  mlFlag:  By default the routine includes the microlens (mlFlag = 1).
%           If mlFlag=0, only vignetting (no microlens included).
%
% Returns
%  ml: Updated microlens structure.  These  fields are updated
%
%        'pixel irradiance'
%        'etendue'
%        'source irradiance'
%        'x coordinate'
%        'p coordinate'
%
%  psImages: Struct that contains images in phase space (x,p) starting at
%     the source, lens offset, and then after the stack to the detector
%
% Example:
%   ml = mlRadiance; plotML(ml,'pixel irradiance')
%   sensor = vcGetObject('sensor'); ml = sensorGet(sensor,'microLens');
%   ml = mlRadiance(ml,sensor,0);    % Bare array, just vignetting
%   ml = mlRadiance(ml,sensor,1);    % Compute accounting for the microlens
%
% See also: mlAnalyzeArrayEtendue, plotML, microLensWindow, v_microlens
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sensor'), sensor = vcGetObject('ISA'); end
if ieNotDefined('ml'), ml = sensorGet(sensor, 'microlens'); end
if ieNotDefined('mlFlag'), mlFlag = 1; end
showBar = ieSessionGet('waitbar');

sourcefNumber = mlensGet(ml, 'source fnumber');

% Get apertures for the pixel, photodetector and microlens aperture in
% microns
mlAperture = mlensGet(ml, 'ml diameter', 'micron');
if mlAperture <= 0, errordlg('Bad microlens diameter: %f\n', mlAperture); end

pixelWidth = sensorGet(sensor, 'pixel width', 'micron');
pdWidth = sensorGet(sensor, 'pixel photodetector width', 'micron');

if mlAperture - pixelWidth > 1000 * eps
    fprintf('mlRadiance: MicroLens diameter %.2f exceeds pixel width %.2f.\n', mlAperture, pixelWidth);
end

% dStack for distance of each layer
% nStack for index of refraction of each layer
dStack = sensorGet(sensor, 'pixel layer thicknesses', 'micron');
nStack = sensorGet(sensor, 'pixel refractive indices');

% Initialization Parameters
nSource = 1; % Index of refraction of source (air)
widthPS = 2 * mlAperture; % [um], Make room for Wigner phase-space X in microns

% Micro-Lens Parameters
% Note: f = f_air and f_stack = stackHeight = n_stack * f_air)
% This is a summary index of refraction of the optical stack.
rStack = 1.52; % Could be computed as the mean of the nStack without air and substrate
f = mlensGet(ml, 'ml focal length', 'micron') / rStack; % [um]
lensOffset = mlensGet(ml, 'offset'); % [um]

% Source Parameters.  There is only one wavelength for each computation,
% hunh.
lambda = mlensGet(ml, 'wavelength', 'um'); % [um]
sourceChiefRayAngle = mlensGet(ml, 'chief ray'); % [deg]

% Wigner PS grids
% Samples in phase space where we calculate
[X, P] = mlCoordinates(-widthPS, widthPS, nSource, lambda, 'angle');
x = X(1, :);
p = P(:, 1);

% Lambertian source.  Numerical aperture associated with the pixel entry
% point (in air)
sourceNA = nSource * sin(atan(1 / (2 * sourcefNumber)));

if showBar, h = waitbar(.1, 'Source'); end

% Computes W the extent of the source as seen by the pixel at the level of
% the microlens.
W_source = mlSource(-mlAperture/2, mlAperture/2, ...
    sin(sourceChiefRayAngle / 180 * pi)-sourceNA, ...
    sin(sourceChiefRayAngle / 180 * pi)+sourceNA, X, P);
psImage.source = W_source;

% Lens
if mlFlag
    if showBar, waitbar(.1, h, 'ML: Lens (be patient)'); end
    % Transform the W representation by the microlens
    [W_lens, X, P] = mlLens(f, lambda, W_source, X, P, 'non-paraxial', 'angle');
else
    % No microlens, no transformation
    W_lens = W_source;
end
psImage.lens = W_source;

% Microlenslens displacement
if mlFlag
    if showBar, waitbar(.5, h, 'ML: Displacement'); end
    % Apply another transformation based on the lens displacement?
    [W_lens_offset, X, P] = ...
        mlDisplacement(lensOffset, W_lens, X, P, 'non-paraxial');
else
    % No lens, no displacement
    W_lens_offset = W_lens;
end
psImage.lensOffset = W_lens_offset;

% Propagation over distance of the stack height (in microns)
% This applies whethere there is a microlens or not
if showBar, waitbar(.7, h, 'ML: Propagate'); end
W_stack = W_lens_offset;

% Propagates for each element of the stack, with its own index of
% refraction.
for ii = 1:length(dStack)
    [W_stack, X, P] = ...
        mlPropagate(dStack(ii), nStack(ii + 1), lambda, W_stack, X, P, 'non-paraxial', 'angle');
end

% The phase-space representation at the detector
W_detector = W_stack;
psImage.detector = W_detector;

if showBar, waitbar(1, h, 'Done'); end
if showBar, delete(h); end

% Map of relative irradiance
% This is a summary of the ray positions at the photodetector
% surface.
% This is the Phase Space representation on the x-axis (space).
% vcNewGraphWin; imagesc(x,p,W_detector);
% xlabel('um'); ylabel('PS thing (between +/-  refractive idx')

% The projection summing across the angular extent
% The max is the largest column.  So the whole projection is normalized by
% the largest column.
psProjected = sum(W_detector, 1) / max(sum(W_detector, 1));
% vcNewGraphWin; plot(x,psProjected)

% Make it 2D because we have only calculated for 1D. This assumes we are
% xy separable. (There is a possibility of doing it circularly but we think
% this is a better approximation because the pixel is square.

% Old form
% pixelIrradiance1 = repmat(psProjected,length(x),1) .* ...
%     rot90(repmat(psProjected,length(x),1));
pixelIrradiance = psProjected(:) * psProjected(:)';

% Check the old and new are the same
% vcNewGraphWin; plot(pixelIrradiance1(:),pixelIrradiance(:),'o')
% max(abs(pixelIrradiance1(:) - pixelIrradiance(:)))

% Set the pixel irradiance
ml = mlensSet(ml, 'pixel irradiance', pixelIrradiance);

% Optical Efficiency calculations
% Find the part of the input irradiance over the pixel aperture and
% add it up.
IrradianceIn = sum(W_source, 1);
etendueIn = sum(IrradianceIn(abs(x) < (pixelWidth / 2)));

IrradianceOut = sum(W_detector, 1);
etendueOut = sum(IrradianceOut(abs(x) < (pdWidth / 2)));
E = etendueOut / etendueIn;

% Attach results to the microlens structure
ml = mlensSet(ml, 'etendue', E);

% This is not really the irradiance! We should call it source phase space.
% (PC)
ml = mlensSet(ml, 'source irradiance', W_source);
ml = mlensSet(ml, 'x coordinate', x);
ml = mlensSet(ml, 'p coordinate', p);

end