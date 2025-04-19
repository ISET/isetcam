function psf = lsf2circularpsf(lsf)
% Convert symmetric 1D line spread function to 2D circularly symmetric PSF
%
% Synopsis
%  psf = lsf2circularpsf(lsf)
%
% Description
%  Convert a symmetric LSF to a circularly symmetric PSF.
%
% Input:
%  lsf - 1D line spread function vector (assumed symmetric and centered,
%        thus odd number of entries, N)
%
% Output:
%  psf - 2D circularly symmetric point spread function (N x N). The
%        returned psf is normalized to have unit volume.
%
% Description (from Psychtoolbox)
%
%   Maps the lsf into the one-dimensional frequency domain (i.e. get the 1D
%   MTF) and then creates a circularly symmetric version.  The 2D frequency
%   representation is then converted back to the spatial domain to produce
%   the psf.  This produces a circularly-symmetric PSF consistent with the
%   measured line spread function.
%
%   This method is described by Marchand, 1964, JOSA, 54, 7, pp. 915-919
%   and is one of several methods provided.  In 1964, taking the Fourier
%   transform was computationally intense. 
%
%   There is a second paper by Marchand (1965, JOSA, 55, 4, 352-354) which
%   treats the more general case where you have line spread functions for
%   many orientations and want to recover an psf that is not necessarily
%   spatially-symmetric.
%
%   The lsf must be spatially symmetric.  This makes sense given that we
%   are going to recover a spatially symmetric psf. The easiest way to
%   insure this is to uses an odd number of lsf samples.
%
%
% See also
%  psf2lsf, psf2otf
%

% Example:
%{
% Create a circularly symmetric PSF
psf = gauss2(16,257,16,257); 

% Convert the psf to an LSF.  Notice that the dimensionality is odd so we
% have a true center
lsf = psf2lsf(psf);

psf2 = lsf2circularpsf(lsf);

% Normalize them both and compare
psf  = psf/max(psf(:));
psf2 = psf2/max(psf2(:));

ieNewGraphWin([],'wide');
tiledlayout(1,2)
nexttile; plot(psf(:),psf2(:),'o'); identityLine
nexttile; mesh(psf2);
%}
%{
% Generate a circularly symmetric Airy disk PSF

% Parameters
n = 301;             % Size of the PSF grid (must be odd for symmetry)
radius = 1.22;       % First zero of Airy pattern in units of wavelength * f-number
pixel_scale = 0.05;  % Radial distance per pixel (arbitrary units)

% Radial coordinate grid
[x, y] = meshgrid(1:n, 1:n);
center = (n + 1) / 2;
r = sqrt((x - center).^2 + (y - center).^2) * pixel_scale;

% Airy disk intensity profile
% I(r) ∝ [2*J1(pi*r/r0)/(pi*r/r0)]^2 where r0 is the first zero radius
k = pi / radius;  % Normalized spatial frequency
kr = k * r;

% Handle r = 0 to avoid divide-by-zero
psf = zeros(size(r));
nonzero = kr ~= 0;
psf(nonzero) = (2 * besselj(1, kr(nonzero)) ./ kr(nonzero)).^2;
psf(~nonzero) = 1;  % lim x->0 [2*J1(x)/x]^2 = 1;

psf  = psf/max(psf(:));

lsf = psf2lsf(psf);

% Enforce pos/neg symmetry
lsf = 0.5*lsf + 0.5*fliplr(lsf);

psf2 = lsf2circularpsf(lsf);

% Normalize them both and compare
psf2 = psf2/max(psf2(:));

ieNewGraphWin([],'wide');
tiledlayout(1,2)
nexttile; plot(psf(:),psf2(:),'o'); identityLine
nexttile; mesh(psf2);

%}

% psf = LsfToPsf(lsf);

n = length(lsf);

% Determine center position
if mod(n, 2) == 0
    center = n/2 + 1;
else
    center = floor(n/2) + 1;
end

% Check symmetry (optional)
neg = lsf(center-1:-1:1);
pos = lsf(center+1:end);
if length(neg) ~= length(pos)
    minlen = min(length(neg), length(pos));
    neg = neg(1:minlen);
    pos = pos(1:minlen);
end
if any(abs(neg - pos) > 1e-10)
    mx = max(abs(neg - pos));
    warning('LSF is not perfectly symmetric.');
end

% Normalize LSF and compute centered 1D OTF
lsf = lsf / sum(lsf(:));
otf1D = fftshift(fft(ifftshift(lsf)));

% Enforce real-valued OTF
if any(abs(imag(otf1D)) > 1e-10)
    error('1D OTF has significant imaginary components.');
end
otf1D = abs(otf1D);

% Create 2D radial frequency grid
[u, v] = meshgrid(1:n, 1:n);
ruv = sqrt((u - center).^2 + (v - center).^2);

% Interpolate the 1D OTF onto the 2D radial grid
if mod(n, 2) == 0
    freq = 0:n/2-1;
else
    freq = 0:floor(n/2);
end
otf2D = interp1(freq, otf1D(center:end), ruv, 'linear', 0);

% Inverse 2D FFT to get PSF
psfComplex = fftshift(ifft2(ifftshift(otf2D)));

% Enforce real-valued PSF
if any(abs(imag(psfComplex(:))) > 1e-10)
    error('2D PSF has significant imaginary components.');
end

psf = abs(psfComplex);
psf = psf / sum(psf(:));  % Normalize

end


%{
% Chat GPT wrote this code without Fourier transforms.  It didn't work as
% well.  I asked it to simplify existing Psychtoolbox code, which used the FT
% domain.  It did, and that's what I used above.
%
% function psf = lsf2circularpsf(lsf)
% lsf2circularpsf Convert 1D line spread function (LSF) to 2D circularly symmetric PSF
%
%   psf = lsf2circularpsf(lsf)
%
%   Input:
%       lsf - 1D line spread function vector (assumed symmetric and centered)
%
%   Output:
%       psf - 2D circularly symmetric point spread function

% Ensure lsf is a column vector
lsf = lsf(:);

n = length(lsf);
center = (n + 1) / 2;  % fractional center for symmetry

% Generate a 2D grid of distances from the center
[x, y] = meshgrid(1:n, 1:n);
r = sqrt((x - center).^2 + (y - center).^2);

% Define radius coordinates corresponding to the LSF
r_lsf = (1:n)' - center;

% Use linear interpolation to map LSF to 2D radial distances
psf = interp1(r_lsf, lsf, r, 'linear', 0);  % outside range set to 0

% Normalize the PSF so it sums to 1
psf = psf / sum(psf(:));
%}