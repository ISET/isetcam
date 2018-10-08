function psf = WestPSFDegrees(radius)
% psf = WestPSFDegrees(radius)
%
% Compute Westheimer's PSF function as a function
% of passed radius.  Radius passed in degrees of arc.
%
% 7/11/94		dhb		Added comments, changed name.

% Call through version that works in minutes.
psf = WestPSFMinutes(radius*60);
