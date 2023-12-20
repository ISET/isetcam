function fResolution = oiFrequencyResolution(oi,units)
% Compute spatial frequency resolution for an optical image
%
%   fResolution = oiFrequencyResolution(oi,units)
%
% Various calculations require knowing the  spatial frequency
% supported by the sampling density of a specific optical image. This
% routine computes the spatial frequency range and resolution given
% the sampling density and size of the optical image.  The fx and fy
% support are returned as arrays in fResolution.fx and fResolution.fy.
%
% This frequency resolution has to be coordinated with the frequency
% support of the OTF stored in a shift-invariant optics model (e.g.,
% diffraction limited, shift-invariant, human).  See oiGet(oi,'fsupport')
% and oiGet(oi,'frequency resolution')
%
% The default units of fResolution are cycles/deg of visual angle. Other
% options are cycles/distance (e.g., cycles/meter, cycles/mm,
% cycles/microns).
%
% Examples:
%    fSmm  = oiFrequencySupport(oi,'mm');   % cycles/millimeter
%    fScpd = oiFrequencySupport(oi,'cycPerDeg');
%    fScpd = oiFrequencySupport(oi);
%
% See also:  
%   sceneFrequencySupport, opticsGet(optics,'otf support')
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('units'), units = 'cyclesPerDegree'; end

% We also begin by calculating the frequencies in cycles per degree of
% visual angle.
%
% oi frequency information
% hangular is height (angular), wangular is width (angular)
fovHeight = oiGet(oi,'hangular');   % oi height in degrees
fovWidth  = oiGet(oi,'wangular');   % oi width in degrees

% If the oi is empty, this returns the number of rows and columns.
nRows = oiGet(oi,'rows');     % Number of oi row and col samples
nCols = oiGet(oi,'cols');

% Next, we compute the spatial frequency list in cycles per degree
% The Nyquist frequency just with respect to the samples is N/2.
% If the oi spans 1 deg, nCols/2 or nRows/2 is the Nyquist frequency in cycles/deg.
% But the oi field of view may differ from one, so we need to divide by
% the true number of degrees.
% For example:
%  If you have 100 spatial samples in a single degree, the Nyquist limit runs to 50 cyc/deg.
%  If the FOV is 40 deg, though, the highest spatial frequency is 50/40 cyc/deg.
maxFrequencyCPD = [(nCols/2)/fovWidth, (nRows/2)/fovHeight];

% Now, if the request is in units other than cyc/deg, we convert
switch lower(units)
    case {'cyclesperdegree','cycperdeg'}
        maxFrequency = maxFrequencyCPD;
    case {'meters','m','millimeters','mm','microns','um'}
        degPerDist = oiGet(oi,'degPerDist',units);
        maxFrequency = maxFrequencyCPD*degPerDist;
    otherwise
        error('Unknown spatial frequency units');
end

% DC = 1.  The first coefficient, K, past the Nyquist is (K-1) > N/2,
% K > (N/2 + 1).  This is managed in the unitFrequencyList routine.
fResolution.fx = unitFrequencyList(nCols)*maxFrequency(1);
fResolution.fy = unitFrequencyList(nRows)*maxFrequency(2);

end
