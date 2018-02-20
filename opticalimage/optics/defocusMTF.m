function OTF = defocusMTF(optics,frequencySupport,defocus)
% Diffraction limited MTF at a particular wavelength for a given defocus
%
%    OTF = defocusMTF(optics,frequencySupport,defocus)
%
%  PROBABLY OBSOLETE.  See opticsDefocusedMTF instead.
%
%  The main application of the routine is to calculate the OTF for human
%  chromatic aberration image (see humanCore) and for defocus of objects
%  that are at different distances from a model thin lens
%  (opticsDepthDefocus).
%
%  optics:             Optics structure
%  frequencySupport:   frequencySupport [nRows x nCols x 2]
%  defocus: This is the w20 parameter, as defined by Hopkins. The Hopkins
%           formula discussion in humanCore and below. This is a vector
%           that describes defocus as a function of wavelength.
%
%  This routine is called from humanCore, and the example therein shows how
%  to set up the parameters.
%
%  See also:  opticsDepthDefocus, opticsDefocusedMTF, humanCore,
%  s_opticsDepthDefocus
%    
% Discussion.
%  The defocus in diopters for different thin lens to sensor distances is
%  computed in opticsDepthDefocus. The defocus for human chromatic
%  aberration is computed in the humanCore code. 
%
%  The depth and defocus relation involves using the lensmaker's 
%  equation. The degree of defocus depends on the aperture size. See around
%  pages 123-4 in Joe Goodman's book for the case of a square aperture, and
%  there is a formula in the humanCore code for a circular aperture.  This
%  might also be in the Marimont paper on human chromatic aberration.
%
% Example:
%  See the script s_opticsDepthDefocus.
%
% -- Old notes ---
%  We specify all frequencies in cycles per degree. We will convert for
%  people from linepairs/mm to cycles per degree. We specify the MTF for an
%  object at infinity, assuming the image plane is at the focal distance.
%  Obviously, if there is defocus (the object is not at infinity), then
%  this MTF needs to be recalculated. 
% 
%  We will put in a hook so that if we decide to have a different object
%  distance (and thus a different image distance), we can recalculate. 
% 
%   We expect this routine to be very quick so we can quickly get the 2D
%   MTF of the lens and multiply it with the spectrum of the image (freq by
%   freq).  We may end up using some indexing/rounding and table-lookup to
%   make this go faster. 
% 
% INPUT  : optics [structure]
%          wavelength [array]
%          frequencySupport [nRows x nCols x 2]
%
% OUTPUT : optics [structure]
%          - the following field(s) will be generated :
%            -- optics.OTF.OTF [nRows x nCols x nWaves]
%
% Copyright ImagEval Consultants, LLC, 2005.

error('defocusMTF: OBSOLETE.  See opticsDefocusedMTF instead.');
return

nWaves = opticsGet(optics,'nwave');
wavelength = opticsGet(optics,'wavelength');
apertureDiameter = opticsGet(optics,'aperturediameter');
w20 = defocus;

fx = frequencySupport(:,:,1);
fy = frequencySupport(:,:,2);
% nRows = size(fx,1);
% nCols = size(fx,2);

% OTF = zeros(nRows,nCols,nWaves);

% We are expecting wavelength to be in nanometers.  This converts it to
% meters.  Check this.
wavelength = wavelength*1e-9;

% This should be parallel to the computation in humanCore
s     = zeros(length(fx),length(fy),nWaves);
alpha = zeros(size(s));
otf   = zeros(size(s));
for ii=1:nWaves
    
    % [lp/degree]
    % Reference to formula would be useful here.  More description -- BW.
    incoherentCutoffFrequency = (apertureDiameter/wavelength(ii))*(pi/180);
    
    % Frequencies up to incoherent cutoff are used.  Everything else is 0.
    % Check this and try to simplify this formula.  It seems needlessly
    % complicated.
    phi = acos(abs(sqrt(fx.^2+fy.^2))/incoherentCutoffFrequency);
    phi((abs(sqrt(fx.^2+fy.^2))/incoherentCutoffFrequency) > 1) = 0;
    
    % See comments in humanCore and opticsDefocusedMTF.
    % dimensionless.  Runs between -2 and 2.
    s(:,:,ii)     = 2*cos(phi);  
    
    %                      (1/m)           m        dimensionless
    alpha(:,:,ii) = 4*pi./wavelength(ii).*w20(ii).*s(:,:,ii);
    
    otf(:,:,ii)   = opticsDefocusedMTF(s(:,:,ii),abs(alpha(:,:,ii)));
    
end

OTF = ones(size(otf));
OTF(isfinite(otf)) = otf(isfinite(otf));

return;
