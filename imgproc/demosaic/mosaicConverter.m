function [bayer_out, outBayerPattern] = mosaicConverter(bayer_in, inBayerPattern, outBayerPattern)
% Convert a Bayer pattern to another Bayer format
%
%   [bayer_out, outBayerPattern] = mosaicConverter(bayer_in,inBayerPattern, outBayerPattern);
%
% We use the same demosaic functions for different types of Bayer patterns.
% We do this by transforming any pf the four possible input Bayer pattern
% type into a common format (gr/bg).
%
% This routine does the conversion. It comprises a set of cases that
% convert different Bayer patterns to another Bayer format. By default the
% output Bayer pattern is 'gr/bg' (grbg).
%
% The conversion shifts the data around, so that, for example, rg/gb ->
% gr/bg starts the data at position (1,2) rather than (1,1). Rather than
% changing the size of the data, we copy a false column of data to fill in
% the missing column (in this case).
%
% We count on the user to have analyze image quality in the center.  We
% know that it would be possible to simply crop the data, changing the
% array size.  (Yes, maybe that should be an option.)
%
% Example:
%    oi = oiCompute(sceneCreate,oiCreate);
%    sensor = sensorCompute(sensorCreate,oi);
%    bayer_in = sensorGet(sensor,'volts');
%    cfaPattern = sensorGet(sensor,'cfa pattern');
%    letters = sensorGet(sensor,'filter Color Letters');
%    inPattern = letters(cfaPattern)'; inPattern = inPattern(:)'; outPattern = 'rggb';
%    bayer_out = mosaicConverter(bayer_in,inPattern, outPattern);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('bayer_in'), error('Bayer mosaic required'); end
if ieNotDefined('inBayerPattern'), error('Original Bayer pattern string required'); end
if ieNotDefined('outBayerPattern'), outBayerPattern = 'grbg'; end

% This is the mosaic we create
bayer_out = zeros(size(bayer_in));

switch lower(outBayerPattern)
    case 'grbg'
        switch lower(inBayerPattern)
            case 'grbg'
                % This is the one we can manage
                bayer_out = bayer_in;
            case 'rggb'
                % Turn this format into one we can manage.  There is an infelicity
                % in the first and last columns
                bayer_out(:, 1:(end -1), :) = bayer_in(:, 2:end, :);
                bayer_out(:, end, :) = bayer_in(:, (end -1), :);
    case 'bggr'
        % Turn the image into one we can manage. There is an infelicity in
        % the first and last rows
        bayer_out(1:(end -1), :, :) = bayer_in(2:end, :, :);
        bayer_out(end, :, :) = bayer_in((end-1), :, :);
    case 'gbrg'
        % Turn the image into one we can manage. There is an infelicity in
        % the first and last rows
        bayer_out(1:(end -1), 1:(end -1), :) = bayer_in(2:end, 2:end, :);
        bayer_out(end, :, :) = bayer_in((end-1), :, :);
        bayer_out(:, end, :) = bayer_in(:, (end -1), :);
otherwise
error('Unsupported Bayer RGB pattern');
end
outBayerPattern = 'grbg';

case 'rggb'
switch lower(inBayerPattern)
    case 'grbg'
        bayer_out(:, 1:(end -1), :) = bayer_in(:, 2:end, :);
        bayer_out(:, end, :) = bayer_in(:, (end -1), :);
case 'rggb'
bayer_out = bayer_in;
case 'bggr'
% Turn the image into one we can manage. There is an infelicity in
% the first and last rows
bayer_out(1:(end -1), 1:(end -1), :) = bayer_in(2:end, 2:end, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
bayer_out(:, end, :) = bayer_in(:, (end -1), :);
case 'gbrg'
bayer_out(1:(end -1), :, :) = bayer_in(2:end, :, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
otherwise
error('Unsupported Bayer RGB pattern');
end
outBayerPattern = 'rggb';

case 'bggr'
switch lower(inBayerPattern)
case 'grbg'
% Turn the image into one we can manage. There is an infelicity in
% the first and last rows
bayer_out(1:(end -1), :, :) = bayer_in(2:end, :, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
case 'rggb'
% Turn the image into one we can manage. There is an infelicity in
% the first and last rows
bayer_out(1:(end -1), 1:(end -1), :) = bayer_in(2:end, 2:end, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
bayer_out(:, end, :) = bayer_in(:, (end -1), :);
case 'bggr'
% This is the one we can manage
bayer_out = bayer_in;

case 'gbrg'
bayer_out(:, 1:(end -1), :) = bayer_in(:, 2:end, :);
bayer_out(:, end, :) = bayer_in(:, (end -1), :);
otherwise
error('Unsupported Bayer RGB pattern');
end
outBayerPattern = 'bggr';

case 'gbrg'
switch lower(inBayerPattern)
case 'grbg'
% Turn the image into one we can manage. There is an infelicity in
% the first and last rows
bayer_out(1:(end -1), 1:(end -1), :) = bayer_in(2:end, 2:end, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
bayer_out(:, end, :) = bayer_in(:, (end -1), :);
case 'rggb'
bayer_out(1:(end -1), :, :) = bayer_in(2:end, :, :);
bayer_out(end, :, :) = bayer_in((end-1), :, :);
case 'bggr'
bayer_out(:, 1:(end -1), :) = bayer_in(:, 2:end, :);
bayer_out(:, end, :) = bayer_in(:, (end -1), :);
case 'gbrg'
% This is the one we can manage
bayer_out = bayer_in;
otherwise
error('Unsupported Bayer RGB pattern');
end
outBayerPattern = 'gbrg';
otherwise
error('Unsupported Bayer RGB pattern');
end

return;
