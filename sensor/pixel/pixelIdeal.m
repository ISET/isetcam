function pixel = pixelIdeal(pixel)
% Create a matched pixel without any noise
%
%     pixel = pixelIdeal(pixel);
%
% Input
%   pixel:  A pixel structure; if empty, the default pixel is used
%
% Return
%   pixel:  The read noise and dark voltage are zeroed.  The voltage swing is
%   1e6.
%
% Example
% Create an ideal pixel based on default pixel.
%   pixelI = pixelIdeal;
%
% Match the pixel, but eliminate the noise
%   pixel  = pixelCreate;
%   pixel  = pixelSet(pixel,'size same fillfactor',[1.5 1.5]*1e-6);
%   pixelI = pixelIdeal(pixel);
%
% Copyright Imageval LLC, 2013

if ieNotDefined('pixel'), pixel = pixelCreate('default'); end

% The spectral QE is all 1 by default

%
pixel = pixelSet(pixel, 'readNoiseVolts', 0); % No read noise
pixel = pixelSet(pixel, 'darkVoltage', 0); % No dark noise
pixel = pixelSet(pixel, 'voltage swing', 1e6); % 1,000,000 volts

return