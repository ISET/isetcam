function [OTF2D, fSupport, wave] = humanOTF(pRadius, D0, fSupport, wave)
% Calculate the human OTF, including chromatic aberration
%
%  [OTF2D, fSupport, wave] = ...
%        humanOTF([pRadius = 0.0015], [D0 = 59.9404], [fSupport = :],[wave = :])
%
% Inputs
%  pRadius - Pupil radius in meters
%  D0      - Dioptric power (1/m)
%  fSupport - Frequency support  (cyc/deg)
%  wave     - wavelength (nm)
%
% Returns
%  OTF2D - Two D optical transfer function for each wavelength
%  fSupport - Frequency support for row,col dimensions of OTF2D
%  wave - wave
%
% The spatial frequency range is determined by the spatial extent and
% sampling density of the original scene.
%
% There is a long discussion below.  This code is based on the analysis in
% Marimont & Wandell (1994 --  J. Opt. Soc. Amer. A,  v. 11, p.
% 3113-3122 -- see also Foundations of Vision by Wandell, 1995.)
%
% See Also:  humanLSF, sceneGet(scene,'frequencyresolution')
%
% Example:
%   [OTF2D, fSupport, wave] = humanOTF(0.0015,60);
%   vcNewGraphWin;
%   mesh(fSupport(:,:,1),fSupport(:,:,2),abs(fftshift(OTF2D(:,:,15))));
%   title('550 nm'); xlabel('Frequency (cyc/deg)'), zlabel('Relative amp')
%   subplot(1,2,2), mesh(fSupport(:,:,1),fSupport(:,:,2), fftshift(abs(OTF2D(:,:,3))));
%   set(gca,'zlim',[-.2,1]);
%   xlabel('Frequency (cyc/deg)'), zlabel('Relative amp'); title('400 nm')
%
% Reference and discussion
%
% We build the otf by first using Hopkins' formula of an eye with only
% defocus and chromatic aberration.  Then, we multiply in an estimate of
% the other aberrations.  At present, we are using some data from Dave
% Williams and colleagues measured using double-pass and threshold data.
%
% Williams et al. (19XX) predict the measured MTF at the infocus wavelength by
% multiplying the diffraction limited OTF by a weighted exponential.
% We perform the analogous calculation at every wavelength.  That is, we
% multiply the aberration-free MTF at each wavelength by the weighted
% exponential in the Williams measurements.  Speaking with Dave last month,
% he said his current experimental observations confirmed that this was
% an appropriate correction.  (BW 05.24.96).
%
% As a further simplification, the human measurements are all 1D.  We build
% a 1D function and then we assume that the true function is circularly
% symmetric.  That is how we fill in the full 2D MTF.  We call it an OTF
% and assume there is no phase shift ...  All an approximation, but
% probably OK for these types of calculations.  Further details could be
% sought out in the recent papers from the Spanish group (e.g. Artal) and
% from Williams and the other Hartmann Shack people.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Default human pupil diameter is 3mm.  This code wants the radius.
if ieNotDefined('pRadius'), p = 0.0015; else p = pRadius; end

% dioptric power of unaccomodated eye (17 mm focal length)
if ieNotDefined('D0'), D0 = 1/0.017; end

% Wavelength in nanometers
if ieNotDefined('wave'), wave = (400:700); end
nWave = length(wave);

% We use a frequency support that covers 60 cyc/deg.
% The frequency support runs from -60:60 by default.
if ieNotDefined('fSupport')
    maxF = 60;
    fList = unitFrequencyList(maxF);
    fList = fList*maxF;
    [X,Y] = meshgrid(fList,fList);
    fSupport(:,:,1) = X; fSupport(:,:,2) = Y;
end

% We treat the OTF as a circularly symmetric function.  We treat the
% effective frequency as the distance from the origin.
dist = sqrt((fSupport(:,:,1).^2 + fSupport(:,:,2).^2));
t = max(fSupport(:,:,1)); maxF1 = max(t(:));
t = max(fSupport(:,:,2)); maxF2 = max(t(:));
% mesh(dist)

%  We don't want to allow any output frequencies beyond the circle defined
%  by the minimum of the two largest frequencies.  We will zero those terms
%  later.
maxF = min(maxF1,maxF2);  % Highest effective spatial freq (cyd/deg)

% The human OTF is smooth.
% To speed up calculations, we use 40 samples and interpolate the other
% values. The sample spatial frequencies are in cycles per degree.
sampleSF = ((0:39)/39)*maxF;
otf      = humanCore(wave,sampleSF,p,D0);
% vcNewGraphWin;
% [x,y]=meshgrid(wave,sampleSF);
% mesh(x',y',abs(otf)); % some values are complex
% xlabel('wavelength'); ylabel('cycles/degree')
% title('Human OTF')

% Interpolate the full 2D OTF from the individual values.
[r,c] = size(fSupport(:,:,1));
OTF2D = zeros(r,c,nWave);
l = (dist > maxF);

for ii=1:nWave
    %    waitbar(ii/nWave,wBar);
    % We have small imaginary values sometimes.  Probably rounding error
    % in some calculation above.  We remove them here.
    tmp = abs(interp1(sampleSF,otf(ii,:),dist,'spline'));
    
    % We don't want any frequencies beyond the sampling grid.  Here we
    % zero them out.
    tmp(l) = 0;
    
    % This is the proper storage format for the OI-ShiftInvariant case.
    OTF2D(:,:,ii) = fftshift(tmp);
end

return;
