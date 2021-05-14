function [alpha, rSF, w20] = opticsReducedSFandW20(optics,wave,dist)
%Compute the human optical transfer function
%
%   [alpha, rSF, w20]  = opticsDefocusParameters(optics,wave,dist)
%
% The derivation of the parameters needed for the defocus OTF are computed
% here.
%
% Needed ...
%  p:         Pupil radius in meters (computed from f/# and focal length)
%  D0:        Base dioptric power (accomodation), usually around 60
%  sampleSF:  Spatial frequencies in cycles/deg
%  wave:      Wavelength in nanometers
%
%Returns
% otf:  Optical transfer function (actually, this is the MTF, just a set of
%       scale factors.  We assume there is no frequency-dependent phase
%       shift.
% ....
%
% Use the Marimont paper to get more references for this routine. There are
% comments below about the Hopkins formula.  These should be moved to a
% wiki page or perhaps the routine opticsDefocusedMTF.
%
% Copyright ImagEval Consultants, LLC, 2010.

% TODO
%  We need a form of this same function that calls opticsDefocusedMTF for a
%  lens imaging a plane that is out of the good focal distance.  Then, if
%  we have a depth map, we compute the defocus (D) and apply this formula -
%  without using the williamsFactor.
%
%

% Constants for formula to compute defocus in diopters (D) as a function of
% wavelength for human eye.  Need citation, but the curve is in my book.
% Not sure where the formula comes from.
q1 = 1.7312; q2 = 0.63346; q3 = 0.21410;

% This is the human defocus as a function of wavelength.  This formula
% converts the wave in nanometers to wave in microns.  D is in diopters.
D = q1 - (q2./(wave*1e-3 - q3));
% plot(wave,D);
% grid; xlabel('Wavelength (nm)'); ylabel('relative defocus (diopters)');

% Converts the defocus in diopters to the Hopkins w20 parameter for a
% given pupil radius in meters, defocus (D, diopters), and dioptric power
% (D0).  The explanation for this formula should be in Marimont and
% Wandell.  I hope.
w20 = p^2/2*(D0.*D)./(D0+D);
% plot(wave,w20);
% grid; xlabel('Wavelength (nm)'); ylabel('relative defocus (Hopkins w20)');

% There is a typical human OTF scaling we use from the work at Dave
% Williams' lab.  Here is a smooth fit to their data.  This was provided by
% Dave Brainard and could be updated or drawn from the literature in some
% other way.  Perhaps from Ijspeert?
a =  0.1212;		%Parameters of the fit
w1 = 0.3481;		%Exponential term weights
w2 = 0.6519;
williamsFactor =  w1*ones(size(sampleSF)) + w2*exp( - a*sampleSF );

% We use this factor to convert from the input spatial frequency units
% (cycles/deg) to cycles/meter needed for the Hopkins eye
c = 3434.07;            % degrees per meter for human eye

s     = zeros(length(wave),length(sampleSF));
alpha = zeros(size(s));
otf   = zeros(size(s));

for ii = 1:length(wave)
    
    % Compute the reduced spatial frequency (0,2)
    %         deg/m * m *          (m/m) * 1/deg  - Dimensionless in the end
    s(ii,:) = (c * wave(ii)*1e-9 /(D0*p)) * sampleSF;
    
    % Related to the defocus specified by w20, which in turn depends on p
    % D and D0.
    alpha(ii,:) = 4*pi./(wave(ii)*1e-9 ).*w20(ii).*s(ii,:);
    
    % We put the vector of sample SF into this array.
    % Then we interpolate to the full 2D array outside of this loop.
    otf(ii,:) = opticsDefocusedMTF(s(ii,:),abs(alpha(ii,:)));
    
    % Combine the Williams human measurements.  The otf() variable now
    % represents the Hopkins OTF combined with the further distortions
    % measured for a typical human eye by Williams.  Each row is for a
    % different wavelength.  In the next move, when we return to the
    % calling routine, humanOTF, we interpolate these values from sampleSF
    % and wave into the full OTF2D at the frequencySupport spacing.
    otf(ii,:) = otf(ii,:).*williamsFactor;
    
end

return;
