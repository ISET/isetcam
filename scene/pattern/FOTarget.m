function RGB = FOTarget(pattern, parms)
%Create a frequency/orientation image
%
%  target = FOTarget(pattern,parms)
%
%Purpose:
%  This target is a black and white image divided into a set of blocks.
%  Each block has a different spatial frequency pattern at one of several
%  orientations. The patterns increase in spatial frequency along the
%  horizontal dimension and change in orientation along  the vertical
%  dimension. This pattern is well-suited for evaluating demosaicing and
%  spatial image processing.
%
%  The spatial patterns can be either square waves or sinusoids.  At high spatial
%  frequencies, the optics in a real camera does not produce square waves.  So,
%  in general we recommend using the sinusoidal format for testing.
%
%  The detailed parameters of the harmonic patterns and their orientations
%  are set in the parms structure, as explained below.
%
% Example:
%  The number of blocks, spatial frequency values, and contrast are set by
%  the entries of the parms variable as in the example:
%
%   parms.angles = linspace(0,pi/2,5);
%   parms.freqs =  [1,2,4,8,16];
%   parms.blockSize = 64;
%   parms.contrast = .8;
%   target = FOTarget('sine',parms);
%   imshow(target)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Read the input parameters
if ~isfield(parms, 'angles'), angles = linspace(0, pi/2, 8);
else angles = parms.angles;
end
if ~isfield(parms, 'freqs'), freqs = 1:8;
else freqs = parms.freqs;
end
if ~isfield(parms, 'contrast'), contrast = 1;
else contrast = parms.contrast;
end
if ~isfield(parms, 'blockSize'), blockSize = 32;
else blockSize = parms.blockSize;
end

% Create the spatial grid
x = [0:blockSize - 1] / blockSize;
[X, Y] = meshgrid(x, x);

% Initialize parameters
ii = 0;
im = [];

switch lower(pattern)
    case 'sine'
        for f = freqs
            thisBlock = [];
            for theta = angles
                thisBlock = [thisBlock, 0.5 * (1 + contrast * sin(2 * pi * f * (cos(theta) * X + sin(theta) * Y)))];
            end
            im = [im; thisBlock];
        end
    case 'square'
        for f = freqs
            thisBlock = [];
            for theta = angles
                thisBlock = [thisBlock, 0.5 * (1 + contrast * square(2 * pi * f * (cos(theta) * X + sin(theta) * Y)))];
            end
            im = [im; thisBlock];
        end
    otherwise
        error('FOTarget:  Unrecognized pattern');
end

% We prefer the frequency variation from left to right.
im = im';
RGB = repmat(im, [1, 1, 3]);
% imshow(RGB)

return;
