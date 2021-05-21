function [outImage, d] = displayCompute(d, I, sz)
% Computes the upsampled subpixel level image to use in creating a scene
%
%    [outImage,d] = displayCompute(d, I, varargin)
%
%  Inputs:
%    display  - could be either display name or display structure, see
%               displayCreate for detail
%    I        - input image, should be M*N*k matrix. k should be equal to
%               the number of primaries of display
%    sz       - oversample size
%
%  Output:
%    outImage - upsampled image, should be in Ms * Ns * k matrix. Default
%               value for upscaling factor s is equal to size(d.psfs, 1)
%
% Examples:
%    display  = displayCreate('LCD-Apple');
%    outImage = displayCompute(display, ones(32));
%    vcNewGraphWin; imagescRGB(outImage);
%
%    I = 0.5*(sin(2*pi*(1:32)/32)+1); I = repmat(I,32,1);
%    outImage = displayCompute('LCD-Apple', I);
%    vcNewGraphWin; imagescRGB(outImage);
%
%    nPixSamples = 10;
%    outImage = displayCompute('LCD-Apple', ones(32), nPixSamples);
%    vcNewGraphWin; imagescRGB(outImage);
%
%  (HJ) April, 2014

%% Init
%  check inputs and init parameters
if ieNotDefined('d'), error('display required'); end
if ieNotDefined('I'), error('Input image required'); end

if ischar(d), d = displayCreate(d); end
if ischar(I), I = im2double(imread(I)); else I = double(I); end


%% Upsampling
nPrimary = displayGet(d, 'n primaries');

% If no upsampling, then s is the size of the psf
if ieNotDefined('sz')
    s = displayGet(d, 'over sample');
    dixelImg = displayGet(d, 'dixel image');
    sz = displayGet(d, 'dixel size');
else
    s = round(sz ./ displayGet(d, 'pixels per dixel'));
    dixelImg = displayGet(d, 'dixel image', sz);
    assert(all(s>0), 'bad up-sampling sz');
end

% check psfs values to be no less than 0
if isempty(dixelImg), error('psf not defined for display'); end
assert(min(dixelImg(:)) >= 0, 'psfs values should be non-negative');

% If a single matrix, assume it is gray scale
if ismatrix(I), I = repmat(I, [1 1 nPrimary]); end

% Expand the image so there are s samples within each of the pixels,
% allowing a representation of the psf.
[M, N, ~] = size(I);
ppd = displayGet(d, 'pixels per dixel');
hRender = displayGet(d, 'render function');

if any(ppd) > 1 && isempty(hRender)
    error('Render algorithm is required');
end

if ~isempty(hRender)
    outImage = hRender(I, d, sz);
else
    outImage = imresize(I, [s(1)*M s(2)*N], 'nearest');
end

% check the size of outImage
assert(size(outImage, 1) == M*s(1) && ...
    size(outImage, 2) == N*s(2), 'bad outImage size');

%
outImage = outImage .* repmat(dixelImg, [M/ppd(1) N/ppd(2) 1]);

end
%% END