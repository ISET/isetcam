function [otf, achOTF] = humanCore(wave,sampleSF,p,D0)
%Compute the human optical transfer function
%
%   [otf, achOTF] = humanCore(wave,nWave,sampleSF,p,D0)
%
% Calculate the human OTF.
%
% Inputs
%  p:         Pupil radius in meters (computed from f/# and focal length)
%  D0:        Base dioptric power (accomodation), usually around 60
%  sampleSF:  Spatial frequencies in cycles/deg
%  wave:      Wavelength in nanometers
%
%Returns
% otf:  Optical transfer function (actually, this is the MTF, just a set of
%       scale factors.  We assume there is no frequency-dependent phase
%       shift.
% williamsFactor: This is a general loss of contrast, independent of
%                 wavelength, that is applied to bring the data into
%                 register with human optics.  That factor comes from
%                 empirical measurements out of the Williams' lab.
%
% Example:
%   wave = 400:10:700; sampleSF = [0:1:30];
%   p = 0.0015; D0 = 60;
%   otf = humanCore(wave,sampleSF,p,D0);
%   mesh(sampleSF,wave,otf)
%
% Use the Marimont paper to get more references for this routine, which is
% mainly based on derivations by Hopkins. There are comments below about
% the Hopkins formula.  These comments should be placed on a wiki page as
% well, and perhaps the routine opticsDefocusedMTF.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Retrieve the defocus, in diopters, at each wavelength.  These are classic
% data.  See the function.
D = humanWaveDefocus(wave);

% Converts the defocus in diopters to the Hopkins w20 parameter for a
% given pupil radius in meters, defocus (D, diopters), and dioptric power
% (D0).  The explanation for this formula is in Marimont and Wandell.
w20 = p^2/2*(D0.*D)./(D0+D);
% plot(wave,w20);
% grid; xlabel('Wavelength (nm)'); ylabel('relative defocus (Hopkins w20)');

% We use this factor to convert from the input spatial frequency units
% (cycles/deg) to cycles/meter needed for the Hopkins eye
% c = 3434.07;            % degrees per meter for human eye
c = 1/(tan(deg2rad(1))*(1/D0));  % deg per meter

% This is the general OTF, independent of wavelength.  The curve here is
% derived from data obtained by Dave Williams.  It could come from some
% other source in the future.
achOTF = humanAchromaticOTF(sampleSF);

s     = zeros(length(wave),length(sampleSF));
alpha = zeros(size(s));
otf   = zeros(size(s));
lambda = wave * 1e-9;

for ii = 1:length(wave)
    
    % Compute the reduced spatial frequency (0,2)
    %            m *           (m/m) *  cy/m  - Dimensionless in the end
    s(ii,:) = ( c * lambda(ii) /(D0*p)) * sampleSF;
    % s(ii,:) = ( lambda(ii) /(D0*p)) * sampleSFm;
    
    % Related to the defocus specified by w20, which in turn depends on p,
    % D and D0.
    alpha(ii,:) = ((4*pi)./(lambda(ii) )).*w20(ii).*s(ii,:);
    
    % We put the vector of sample SF into this array.
    % Then we interpolate to the full 2D array outside of this loop.
    otf(ii,:) = opticsDefocusedMTF(s(ii,:),abs(alpha(ii,:)));
    
    % Combine the Williams human measurements.  The otf() variable now
    % represents the Hopkins OTF combined with the further distortions
    % measured for a typical human eye by Williams.  Each row is for a
    % different wavelength.  In the next move, when we return to the
    % calling routine, humanOTF, we interpolate these values from sampleSF
    % and wave into the full OTF2D at the frequencySupport spacing.
    otf(ii,:) = otf(ii,:).*achOTF;
    
end

end
