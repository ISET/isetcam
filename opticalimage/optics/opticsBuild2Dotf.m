function optics = opticsBuild2Dotf(optics,otf,sampleSF)
%Create a 2D OTF representation from the 1D wave x OTF data
%
%   optics = opticsBuild2Dotf(optics,otf,sampleSF)
%
% We calcute the otf(wave,freq) using opticsDefocusedMTF and
% opticsDefocusCore.  We then need to convert that data into the format
% used by an optics structure. This one stores the frequency support
% running from [-f,f]
%
%  optics: ISET optics structure
%  otf:    Optical transfer function matrix, otf(wave,sf)
%  sampleSF:  Spatial frequency samples in cyc/mm (all positive).
%
% Return
%  OTF2D:     OTF appropriate for storing in optics (includes -f,f)
%  fSupport:  Spatial frequency support for OTF2D (cyc/mm)
%
% See also:  customOTF, humanOTF
%
% Example:
%
%  optics = opticsBuild2Dotf(optics,otf,sampleSF);
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('optics'), error('optics required'); end
if ieNotDefined('otf'),    error('otf data rquired'); end
if ieNotDefined('sampleSF'),  error('spatial frequency range required.'); end

% Frequency representation in optics structure
% Units are cyc/mm
% We want the frequency for this to be negative and positive
% I think there needs to be a DC term ...
% fSupport = [-fliplr(sampleSF) sampleSF(2:end)];

% We create a circularly symmetric OTF.
%
% Now make a proper list of spatial frequencies for the interpolated OTF2D.
% This list is stored in the 'otf fx' slot as the sample spatial
% frequencies.  It is also used in the dist calculation.
%
% N.B.  This spatial frequency gets too high sometimes and can slow down
% the calculation.  The maxF may be, say 1000 cyc/mm in which case we would
% need 2 samples / micron to measure at that level.  Pixels are only about
% 2 microns, maybe 1 micron.  Not sure what to do here.  Could just leave
% it or we could think more.
%
% Also, we should be thinking about diffraction cutoff.
mx   = max(sampleSF(:));
maxF = ceil(max(sqrt(mx^2 + mx^2)));
fSupport = unitFrequencyList(maxF)*maxF;
[fX,fY] = meshgrid(fSupport,fSupport);

% This is the effective spatial frequency (effSF) for each point in the OTF
% matrix. We interpolate the OTF to these values.  The fX values are the
% samples along the x and y axes.
effSF = sqrt((fX.^2 + fY.^2));
% mesh(fX,fY,effSF)

% Interpolate the 2D OTF from the rows of otf.
[r,c] = size(fX);
nWave = size(otf,1);
OTF2D = zeros(r,c,nWave);

% We will set out of range values to 0 in the loop
l = (effSF > maxF);   %sum(l(:))

showWbar = ieSessionGet('waitbar');
if showWbar, h = waitbar(0,'Build Defocused OTF'); end
for ii=1:nWave
    if showWbar, waitbar(ii/nWave,h); end
    
    % sampleSF in c/mm.  otf(ii,:) calculated in opticsDefocusedMTF
    % effSF is the effective spatial frequency of the support in c/mm
    % tmp = abs(interp1(sampleSF,otf(ii,:),effSF,'spline'));
    tmp = abs(interp1(sampleSF,otf(ii,:),effSF,'linear',0));
    % mesh(fX,fY,tmp)
    
    % We don't want any frequencies beyond the sampling grid.  Here we
    % zero them out.
    tmp(l) = 0;
    % mesh(fX,fY,tmp)
    
    % This is the proper storage format for the OI-ShiftInvariant case.
    OTF2D(:,:,ii) = ifftshift(tmp);
    % imagesc(OTF2D(:,:,ii))
    
    % Verify that OTF2D(1,1,:) is 1
    if OTF2D(1,1,ii) ~= 1
        disp('Adjusting DC level to 1.')
        OTF2D(:,:,ii) = OTF2D(:,:,ii) / OTF2D(1,1,ii);
    end
    
    % But it is the bottom line, not the top, that has the DC term in it.
    % I am not sure why.
    % If things are good then we should be able to see a nice line spread
    % function here. We invert the OTF along that line to get an LSF.  We
    % apply the fftshift because we want the lsf to be centered.
    % Compute the LSF
    %   lsf = ifftshift(ifft(OTF2D(1,:,ii))); plot(lsf);
    % Why isn't this 1, given that otf(0) = 1?
    %   sum(lsf(:))
    
end
if showWbar, close(h); end

% Now set the OTF2D and fx,fy data into the optics structure.
optics = opticsSet(optics,'otfData',OTF2D);
optics = opticsSet(optics,'otf fx',fSupport);
optics = opticsSet(optics,'otf fy',fSupport);

return
