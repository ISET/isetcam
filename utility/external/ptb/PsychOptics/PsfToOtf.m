function [xSfGridCyclesDeg,ySfGridCyclesDeg,otf] = PsfToOtf(xGridMinutes,yGridMinutes,psf,varargin)
% Convert a 2D point spread function to a 2D optical transfer fucntion.
%    [xSfGridCyclesDeg,ySfGridCyclesDeg,otf] = PsfToOtf([xGridMinutes,yGridMinutes],psf,varargin)
%
%    Converts a point spread function specified over two-dimensional
%    positions in minutes to a optical transfer function specified over
%    spatial frequency in cycles per degree.  For human vision, these are
%    each natural units.
%
%    The input positions should be specified in matlab's grid matrix format
%    and x and y should be specified over the same spatial extent and with
%    the same number of evenly spaced samples. Position (0,0) should be at
%    location floor(n/2)+1 in each dimension.  The OTF is returned with
%    spatial frequency (0,0) at location floor(n/2)+1 in each dimension.
%
%    Spatial frequencies are returned using the same conventions.
%
%    If you want the spatial frequency representation to have frequency
%    (0,0) in the upper left, as seems to be the more standard Matlab
%    convention, apply ifftshift to the returned value.  That is
%       otfUpperLeft = ifftshift(otf);
%    And then if you want to put it back in the form for passing to our
%    OtfToPsf routine, apply fftshift:
%       otf = fftshift(otfUpperLeft);
%    The isetbio code (isetbio.org) thinks about OTFs in the upper left
%    format, at least for its optics structure, which is one place where
%    you'd want to know this convention.
%
%    No normalization is performed.  If the phase of the OTF are very small
%    (less than 1e-10) the routine assumes that the input psf was spatially
%    symmetric around the origin and takes the absolute value of the
%    computed otf so that the returned otf is real.
%
%    We wrote this rather than simply relying on Matlab's potf2psf/psf2otf
%    because we don't understand quite how that shifts position of the
%    passed psf and because we want a routine that deals with the
%    conversion of spatial support to spatial frequency support.
%
%    If you pass the both position args as empty, both sf grids are
%    returned as empty and just the conversion on the OTF is performed.
%
%    PsychOpticsTest shows that this works very well when we go back and
%    forth for diffraction limited OTF/PSF.  But not exactly exactly
%    perfectly.  A signal processing maven might be able to track down
%    whether this is just a numerical thing or whether some is some small
%    error, for example in how position is converted to sf or back again in
%    the OtfToPsf.
%
%    See also OtfToPsf, PsychOpticsTest.

% History:
%   01/26/18  dhb  We used to zero out small imaginary values.  This,
%                  however, can cause numerical problems much worse than
%                  having small imaginary values in the otf.  So we don't
%                  do it anymore.

%% Handle sf args and converstion
if (~isempty(xGridMinutes) & ~isempty(yGridMinutes))
    % They can both be passed as non-empty, in which case we do a set of sanity
    % checks and then do the conversion.
    [m,n] = size(xGridMinutes);
    centerPosition = floor(n/2) + 1;
    if (m ~= n)
        error('psf must be passed on a square array');
    end
    [m1,n1] = size(yGridMinutes);
    if (m1 ~= m || n1 ~= n)
        error('x and y positions are not consistent');
    end
    [m2,n2] = size(psf);
    if (m2 ~= m || n2 ~= n)
        error('x and y positions are not consistent');
    end
    if (~all(xGridMinutes(:,centerPosition) == 0))
        error('Zero position is not in right place in the passed xGrid');
    end
    if (~all(yGridMinutes(centerPosition,:) == 0))
        error('Zero position is not in right place in the passed yGrid');
    end
    if (xGridMinutes(1,centerPosition) ~= yGridMinutes(centerPosition,1))
        error('Spatial extent of x and y grids does not match');
    end
    diffX = diff(xGridMinutes(:,centerPosition));
    if (any(diffX ~= diffX(1)))
        error('X positions not evenly spaced');
    end
    diffY = diff(yGridMinutes(centerPosition,:));
    if (any(diffY ~= diffY(1)))
        error('Y positions not evenly spaced');
    end
    if (diffX(1) ~= diffY(1))
        error('Spatial sampling in x and y not matched');e
    end
    
    % Generate spatial frequency grids
    [xSfGridCyclesDeg,ySfGridCyclesDeg] = PositionGridMinutesToSfGridCyclesDeg(xGridMinutes,yGridMinutes);
    
elseif (isempty(xGridMinutes) & isempty(yGridMinutes))
    % This case is OK, we set the output grids to empty
    xSfGridCyclesDeg = [];
    ySfGridCyclesDeg = [];
    
else
    % This case is not allowable
    error('Either both position grids must be empty, or neither');
end

%% Compute otf
otf = fftshift(fft2(ifftshift(psf)));

end