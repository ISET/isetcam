function [spatial_frequencies, amplitude_spectrum] = ieOneOverF(rgb_image,gamma)
% Computes the radially averaged amplitude spectrum of an RGB image.
%
% Inputs:
%   rgb_image - A 3D array representing the RGB image (M x N x 3).
%   displayGamma -  Exponent applied to convert RGB to linear
%   intensity
%
% Outputs:
%   spatial_frequencies - A 1D array of radial spatial frequencies.
%   amplitude_spectrum - A 1D array of the corresponding radially averaged amplitudes.
%
% Description
%   The spatial frequencies begin as 1:maxdistance where maxdistance
%   is from the center and measured in pixel.  On return, they are
%   normalized to [0,0.5].
%
%   By default rgb values are treated as if they are linear.  That
%   puzzles me, since RGB is usually related to intensity via a gamma
%   function, and it is not usually linear w.r.t. intensity.  I added
%   a gamma parameter to experiment with.  The default is 1.
%

% Example:
%{
rgb_image = imread('stanfordQuadEntry.png');
displayGamma = 2.2;   % This is the default in the routine
[spatial_frequencies, amplitude_spectrum] = ieOneOverF(rgb_image,displayGamma);

ieFigure;
loglog(spatial_frequencies, amplitude_spectrum);
xlabel('Spatial Frequency (normalized)'); ylabel('Amplitude');
title('Radially Averaged Amplitude Spectrum'); grid on;

% logAmp = logFreq*alpha + constant
logAmp = log10(amplitude_spectrum);
logFreq = log10(spatial_frequencies);

% Calculate the slope of the line relating log freq and log amp.
% y = A x
A = [logFreq(:),ones(numel(logFreq),1)];
x = pinv(A)*logAmp(:);
fprintf('logAmp = logFreq*alpha + constant\nalpha = %.3f and constant is %.3f\n',x(1),x(2));
%}

rgb_image = double(rgb_image);
if notDefined('gamma'), gamma = 2.2; end
rgb_image = rgb_image .^ gamma;

% Convert the RGB image to grayscale (e.g., using luminance)
gray_image = 0.2989 * rgb_image(:,:,1) + 0.5870 * rgb_image(:,:,2) + 0.1140 * rgb_image(:,:,3);
%{
 % The coefficients used to calculate grayscale values in the
    im2gray function are identical to those used to calculate
    luminance (E'y) in Rec.ITU-R BT.601-7 after rounding to three
    decimal places. Rec.ITU-R BT.601-7 calculates E'y using this formula:   
    0.299 * R + 0.587 * G + 0.114 * B
%}
% gray_image = im2gray(rgb_image);
gray_image = double(gray_image); % Convert to double for FFT

% Compute the 2D Fast Fourier Transform (FFT)
fft_result = fft2(gray_image);

% Shift the zero-frequency component to the center of the spectrum
shifted_fft = fftshift(fft_result);

% Compute the magnitude spectrum (amplitude)
amplitude = abs(shifted_fft);

% Get the dimensions of the image
[rows, cols] = size(gray_image);

% Create a grid of coordinates
[x, y] = meshgrid(1:cols, 1:rows);

% Calculate the distance of each point from the center
center_x = ceil(cols / 2);
center_y = ceil(rows / 2);
distances = sqrt((x - center_x).^2 + (y - center_y).^2);

% Determine the maximum distance (radius)
max_distance = floor(min(rows, cols) / 2);

% Initialize arrays to store the results
spatial_frequencies = 1:max_distance;
amplitude_spectrum = zeros(1, max_distance);
counts = zeros(1, max_distance);

% Radially average the amplitude spectrum
for i = 1:rows
    for j = 1:cols
        distance = round(distances(i, j));
        if distance <= max_distance && distance > 0
            amplitude_spectrum(distance) = amplitude_spectrum(distance) + amplitude(i, j);
            counts(distance) = counts(distance) + 1;
        end
    end
end

% Normalize the amplitude spectrum by the number of points at each radius
amplitude_spectrum = amplitude_spectrum ./ counts;

% Normalize the spatial frequencies to the range [0, 0.5] (Nyquist frequency)
spatial_frequencies = spatial_frequencies / max(rows, cols);

end