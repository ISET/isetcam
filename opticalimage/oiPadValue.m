function oi = oiPadValue(oi, padSize, padType, sDist, direction)
% Pad the oi irradiance data, usually prior to applying OTF
%
% Syntax:
%   oi = oiPadValue(oi, padSize, padValue, [sDist], direction)
%
% Description:
%    For optics calculations we need to pad the size (to avoid edge
%    wrapping). We pad the oi with one of several possible values.
%
%    mean photon level in the oi
%    zeros
%
%
%    You can set the argument direction = 'both', 'pre', or 'post' to pad
%    both or only on one side. By default, the zero-padding takes place on
%    all sides of the image. Thus, by default if padSize(1) is 3, we add 3
%    rows on top and bottom (total of 6 rows).
%
%    There are examples contained in the code. To access, type 'edit
%    oiPad.m' into the Command Window.
%
% Inputs:
%    oi        - Struct. An optical image structure
%    padSize   - Matrix. A matrix containing the dimensions to pad out.
%    padType  - String. Default: 'mean photons'. How to pad.
%                See validatePadStruct() for valid padValue values
%    sDist     - (Optional) Scalar Numeric. The scene distance. Default is
%                to query from a scene. If no scene, assume 1m.
%    direction - (Optional) String. Direction to pad. Default is 'both'.
%                Options are: 'both', 'pre', or 'post'.
%
% Outputs:
%    oi        - Struct. The modified optical image structure
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * TODO: Assign someone to fix the example. Error is currently "Struct
%    contents reference from a non-struct array object."
%
%
% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC, 2003.
%    03/07/18  jnm  Formatting
%    10/01/18  npc  Updated it to use custom pad size and value
%    06/24/19  JNM  Documentation update

% Examples:
%{
    scene = sceneCreate;
    oi = oiCreate;
    oi = oiCompute(oi,scene);
    oi = oiCrop(oi,'border');
    oi = oiPadValue(oi, [8, 8, 0], 'zero photons');
    oiWindow(oi);
%}

if notDefined('sDist')
    scene = vcGetObject('scene');
    if isempty(scene)
        warning('oiPad: No scene, assuming 1 m sDist');
        sDist = 1;
    else
        sDist = sceneGet(scene, 'distance');
    end
end
if notDefined('direction'), direction = 'both'; end

% We make sure padSize matches the dimensionality of photons.
% Probably not necessary. But ...
if ismatrix(padSize), padSize(3) = 0; end

photons = oiGet(oi, 'photons');
% To prevent an ieCompressData error, we set the surrounding region as the
% mean of the data at each wavelength samples. In this way, we will match
% the mean luminance.
if isa(photons, 'gpuArray')
    meanPhotons = gather(mean(mean(photons)));
else
    meanPhotons = mean(mean(photons));
end

% We use the meanPhotons in all cases to set the proper dimension
% (which is the wavelength dimension).
switch ieParamFormat(padType)
    case 'zerophotons'
        padval = meanPhotons * 0;
    case 'meanphotons'
        padval = meanPhotons;
    case 'borderphotons'
        % The photons at the corner of the optical image
        padval = meanPhotons*0 + photons(1,1,:);
    otherwise
        error('Unknown padType argument: %s', padType);
end

% Pad one wavelength at a time at single
% Compute the size of the new, padded array.
photons = single(photons);
[r, c] = size(padarray(photons(:, :, 1), padSize, padval(1), direction));

% Figure out the number of wavebands
nwave = size(photons, 3);

% Now, use single instead of double precision.
newPhotons = zeros(r, c , nwave, 'single');
for ii = 1 : nwave
    newPhotons(:, :, ii) = ...
        padarray(photons(:, :, ii), padSize, padval(ii), direction);
end

% Clear unused stuff
clear photons;
photons = newPhotons;
clear newPhotons;

% The sample spacing of the optical image at the surface of the sensor must
% be adjusted for the padding. We must make this adjustment before putting
% the new data into the oi because we need to preserve the number of
% columns until we are done with this calculation.

% The width per horizontal sample at the sensor surface is the ratio of the
% width to the number of columns. The new number of columns is the sum of
% the current number and the horizontal pad size, which is in pad(2)

if strcmp(direction, 'both')
    padCols = padSize(2) * 2;
else
    padCols = padSize(2);
end
newWidth = oiGet(oi, 'width') * (1 + padCols / oiGet(oi, 'cols'));

% Find the distance from the image to the lens
imageDistance = oiGet(oi, 'optics image distance', sDist);

% Now we compute the new horizontal field of view using the formula that
% says the opposite over adjacent is the tangent of the angle. We return
% the value in degrees
oi = oiSet(oi, 'h fov', 2 * atand(newWidth / 2 / imageDistance));

% Now we adjust the columns by placing in the new photons
oi = oiSet(oi, 'photons', photons);

end