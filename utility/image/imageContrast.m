function cData = imageContrast(data)
% Compute the image contrast in an RGB style image
%
% cData = imageContrast(data)
%
%    The image contrast is the intensity minus the mean divided by the
%    mean.  Such an image always has zero mean, and can be useful for
%    computing the image MTF, discarding the DC term.
%
% Copyright ImagEval Consultants, LLC, 2005.


cData = zeros(size(data));

for ii = 1:size(data, 3)
    m = mean(mean(data(:, :, ii)));
    cData(:, :, ii) = (data(:, :, ii) - m) / m;
end

return;