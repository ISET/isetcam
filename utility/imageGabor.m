function g = imageGabor(varargin)
%IMAGEGABOR  Create a 2-D Gabor image using inputParser name-value pairs
%
% Synopsis:
%   g = imageGabor('frequency',f, 'phase',p, 'spread',s, 'orientation',t,'imsize',sz)
%
% Name-value arguments (all optional):
%     'frequency'   - spatial frequency in cycles/image (default 5)
%     'phase'       - phase in radians (default 0)
%     'spread'      - Gaussian sigma in pixels (default 10)
%     'orientation' - orientation theta in radians (0 => stripes along x) (default 0)
%     'imagesize'   - Image size (row,col) (default 8*spread, but always made odd)
%     'contrast'    - Gabor image contrast (default 1)
%
% Description
%   The image is returned with a mean of 0.5. 
%   The image size is forced to be odd.
%   The Gaussian envelope is always circular.
%

% Example:
%{
ieFigure; tiledlayout(2,2);

img = imageGabor('contrast',0.1);
nexttile;
imshow(img); axis image; colormap(gray);
assert(max(img(:)) < 0.56 && min(img(:)) > 0.45)

img = imageGabor('frequency',16, 'image size',64,'orientation',pi/4);
nexttile
imshow(img); axis image; colormap(gray);

img = imageGabor('frequency',2, 'spread',32,'orientation',-pi/4,'image size',128,'phase',pi/4);
nexttile;
imshow(img); axis image; colormap(gray); grid on; axis on;
set(gca,'xticklabel','','yticklabel','');

img = imageGabor('frequency',2, 'spread',32,'orientation',-pi/4,'image size',128,'phase',0);
nexttile;
imshow(img); axis image; colormap(gray); grid on; axis on; 
set(gca,'xticklabel','','yticklabel','');
%}

%% Parameter management

defaultFreq = 5;
defaultPhase = 0;
defaultSpread = 10;
defaultTheta = 0;
defaultSize  = 0;
defaultContrast = 1;

% Validation functions
mustBeScalarNonneg = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
mustBeScalarPos = @(x) isnumeric(x) && isscalar(x) && (x > 0);
mustBeScalarReal = @(x) isnumeric(x) && isscalar(x) && isreal(x);

varargin = ieParamFormat(varargin);

p = inputParser;
p.FunctionName = 'gabor2d';
addParameter(p, 'frequency',   defaultFreq,      mustBeScalarNonneg);
addParameter(p, 'phase',       defaultPhase,     mustBeScalarReal);
addParameter(p, 'spread',      defaultSpread,    mustBeScalarPos);
addParameter(p, 'orientation', defaultTheta,     mustBeScalarReal);
addParameter(p, 'imagesize',   defaultSize,      mustBeScalarReal);
addParameter(p, 'contrast',    defaultContrast,  mustBeScalarReal);

parse(p, varargin{:});
freq   = p.Results.frequency;
phase  = p.Results.phase;
sigma  = p.Results.spread;
theta  = p.Results.orientation;
imsize = p.Results.imagesize;
contrast = p.Results.contrast;

% Kernel size: cover ±4*sigma and make odd
if imsize == 0
    halfsize = max(1, ceil(4*sigma));
    [x, y] = meshgrid(-halfsize:halfsize, -halfsize:halfsize);
else
    halfsize = max(1, round(imsize/2));
    [x, y] = meshgrid(-halfsize:halfsize, -halfsize:halfsize);
end

%% Calculations

% Convert freq per image to freq per pixel.
imsize = numel(-halfsize:halfsize);
freq = fImageTofPixel('nCycles',freq,'imageSize',[imsize imsize],'theta',theta);

% Gaussian envelope
gEnv = exp(- (x.^2 + y.^2) / (2 * sigma^2));

% Rotate coordinates for oriented harmonic
xprime = x * cos(theta) + y * sin(theta);

% Harmonic (real Gabor)
harmonic = cos(2*pi*freq .* xprime + phase);

% Gabor patch (real), mean zero
g = contrast * gEnv .* harmonic;

% Center on 0.5 with a peak deviation of 0.5.  All the values are positive.
g = 0.5*g + 0.5;

% Delete this after some time.  This is November 18 2025.
assert(min(g(:)) >= 0 && max(g(:)) <=1);

end

function frequency = fImageTofPixel(varargin)
%CONVERT  Convert cycles-per-image to cycles-per-pixel accounting for orientation
%   frequency = fImageTofPixel(nCycles, imageSize, theta)
%   frequency = fImageTofPixel('nCycles',n,'imageSize',[H W],'theta',t)
%
%   Inputs:
%     nCycles   - desired number of cycles across the image (scalar >= 0)
%     imageSize - [H W] (rows, cols) or scalar (square image); positive integers
%     theta     - orientation in radians (scalar). 0 => stripes along x.
%
%   Output:
%     frequency - cycles per pixel (scalar)

% Defaults
defaultNCycles = 1;
defaultImageSize = [256 256];
defaultTheta = 0;

% Validators
mustBeNonnegScalar = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
mustBePosScalarOrTwo = @(x) (isnumeric(x) && isscalar(x) && (x > 0)) || ...
                          (isnumeric(x) && isvector(x) && numel(x)==2 && all(x > 0));
mustBeRealScalar = @(x) isnumeric(x) && isscalar(x) && isreal(x);

p = inputParser;
p.FunctionName = 'convert';
addOptional(p, 'nCycles', defaultNCycles, mustBeNonnegScalar);
addOptional(p, 'imageSize', defaultImageSize, mustBePosScalarOrTwo);
addOptional(p, 'theta', defaultTheta, mustBeRealScalar);

parse(p, varargin{:});
nCycles = p.Results.nCycles;
imageSize = p.Results.imageSize;
theta = p.Results.theta;

% Normalize imageSize to [H W]
if isscalar(imageSize)
    H = imageSize;
    W = imageSize;
else
    H = imageSize(1);
    W = imageSize(2);
end

% Effective projection length of the sinusoid axis across the image:
span = W * abs(cos(theta)) + H * abs(sin(theta));

% Prevent division by zero (span==0 only if image has zero size)
if span <= 0
    error('Image span must be positive.');
end

% cycles per pixel
frequency = nCycles / span;

end
