%
%			ChromAb
%
% AUTHOR:  Wandell, D. Marimont, X. Zhang
% PURPOSE:
%   A Matlab/C script to perform the chromatic aberration computations
% described in Marimont & Wandell (1994 --  J. Opt. Soc. Amer. A,
% v. 11, p. 3113-3122 -- see also Foundations of Vision by Wandell, 1995.
%
% DATE:  05.24.96
%

% 1. First, create the optical transfer function of the eye for
% different parameters and assuming that there are no optical
% aberrations except for chromatic aberration.  It is a perfect eye,
% except for the chromatic aberration problem.
%
% The program otf is written in C (for SunOs 4.1.3) and is included
% in this directory.  You can have the source code, of course, but it
% was written as part of a larger package so to compile it will take
% some work.
%
% The program takes a variety of parameters that are enterred most
% conveniently by placing them in the file cmd.otf.
%
% If you want to run it stand-alone, just type "otf" at the
% shell, and you will be prompted for the parameters.
%
unix('otf -icmd.otf | pr_mat -d > otf.text');

% These parameters should be the same as in cmd.otf
%
wave = 370:1:730;
sampleSf = 0:32;	% Spatial frequencies used
load -ascii otf.text

save otf otf wave sampleSf

% colormap(cool)
% mesh(sampleSf,wave,otf);
% view([45 30])
% xlabel('Spatial frequency'); ylabel('Wavelength'); zlabel('Modulation')
%

% If you have already created otf, but not combinedOtf,
% then start here.
%
load otf

% 2.  Next, we adjust the otf that contains only chromatic aberration
% by multiplying in an estimate of the other aberrations.  At present,
% we are using some data from Dave Williams and colleagues measured using
% double-pass and threshold data.  He has better data by now and will
% tell us about it, right Dave?
%
% Williams et al. (19XX) predict the measured MTF at the infocus wavelength by
% multiplying the diffraction limited OTF by a weighted exponential.
% We perform the analogous calculation at every wavelength.  That is, we
% multiply the aberration-free MTF at each wavelength by the weighted
% exponential in the Williams measurements.  Speaking with Dave last month,
% he said his current experimental observations confirmed that this was
% an appropriate correction.  (BW 05.24.96).
%
a =  0.1212;		%Parameters of the fit
w1 = 0.3481;		%Exponential term weights
w2 = 0.6519;
williamsFactor =  w1*ones(size(sampleSf)) + w2*exp( - a*sampleSf );
combinedOtf = otf*diag(williamsFactor);

save combinedOtf combinedOtf wave sampleSf

% colormap(cool)
% mesh(sampleSf,wave,combinedOtf)
% view([45 30])
%

% 4. Here is a computation of the associated linespread functions,
% under the assumption of symmetry.
%
% You can start here if you already have computed the stuff above
%
load combinedOtf

%  3.1 Here is the associated linespread at each wavelength, assuming
% a symmetry.
%
nSf = size(combinedOtf,2);
nWave = size(combinedOtf,1);
r = zeros(1,2*nSf - 1);
lineSpread = zeros(nWave,2*nSf - 1);

for i = 1:size(combinedOtf,1)
    r(1:nSf) = combinedOtf(i,1:nSf);
    r(nSf+1:2*nSf - 1) = combinedOtf(i,nSf:-1:2);
    lineSpread(i,:) = fftshift(real(ifft(r)));
end

% Because we have doubled the linespread (see above) the spatial
% extent of the linespread is 2 times the base cycle size used
% in the fft.  We assume that sampleSf(1) is 0 deg, so the base
% spatial frequency is in sampleSf(2).
%
spatialExtentDeg = 2*(1 / sampleSf(2));
xDim = [-(nSf-1):1:(nSf-1)];
xDim = ( xDim/ (length(xDim)-1)) * spatialExtentDeg;

colormap(cool)
mesh(xDim,wave,lineSpread);
view([45 30])
set(gca,'ylim',[min(wave) max(wave)]);

