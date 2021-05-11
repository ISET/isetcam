function fSupport = sceneFrequencySupport(scene, units)
%Compute spatial frequency support for scene in specified units
%
%   fSupport = sceneFrequencySupport(scene,units)
%
% Various calculations, such as the OTF, require the range of spatial
% frequencies in the scene supported by the sampling density.
% This routine, and the company oiFrequencySupport, compute the
% spatial frequency support and return it as an array.
%
% See also:  unitFrequencyList
%
% Examples:
%    fSmm  = sceneFrequencySupport(oi,'mm');   %cycles/millimeter
%    fScpd = sceneFrequencySupport(oi,'cycPerDeg');
%    fScpd = sceneFrequencySupport(oi);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('units'), units = 'cyclesPerDegree'; end

% We also begin by calculating the frequencies in cycles per degree of
% visual angle.
%
% Scene frequency information
% hangular is height (angular), wangular is width (angular)
fovHeight = sceneGet(scene, 'hangular'); % Scene height in degrees
fovWidth = sceneGet(scene, 'wangular'); % Scene width in degrees

if isempty(fovHeight) || isempty(fovWidth)
    % There is no scene spatial resolution.  This happens only when the scene is empty, I think.
    % So, we must make up, from whole cloth, a set of
    % values that will be OK for this angular resolution.  This might be a
    % bad idea.
    disp('sceneFrequencySupport: Making up arbitrary scene angle, 30x30 deg')
    fovWidth = 30;
    fovHeight = 30;
    nCols = fovWidth * 10;
    nRows = fovHeight * 10;
else
    nRows = sceneGet(scene, 'rows'); % Number of scene row and col samples
    nCols = sceneGet(scene, 'cols');
    if isempty(nCols) || isempty(nRows)
        disp('sceneFrequencySupport: Making up spatial sampling 128x128')
        % The optical image has not yet been created.  So we use a default
        % set samples at [128,128]
        nRows = 128;
        nCols = 128;
    end
end

% Next, we compute the spatial frequency list in cycles per degree
% The Nyquist frequency just with respect to the samples is N/2.
% If the scene spans 1 deg, nCols/2 or nRows/2 is the Nyquist frequency in cycles/deg.
% But the scene field of view may differ from one, so we need to divide by
% the true number of degrees.
% For example:
%  If you have 100 spatial samples in a single degree, the Nyquist limit runs to 50 cyc/deg.
%  If the FOV is 40 deg, though, the highest spatial frequency is 50/40 cyc/deg.
maxFrequencyCPD = [(nCols / 2) / fovWidth, (nRows / 2) / fovHeight];

% Now, if the request is in units other than cyc/deg, we convert
switch lower(units)
    case {'cyclesperdegree', 'cycperdeg', 'cpd'}
        maxFrequency = maxFrequencyCPD;
    case {'meters', 'm', 'millimeters', 'mm', 'microns', 'um'}
        degPerDist = sceneGet(scene, 'degPerDist', units);
        maxFrequency = maxFrequencyCPD * degPerDist;
    otherwise
        error('Unknown spatial frequency units');
end

% DC = 1.  The first coefficient, K, past the Nyquist is (K-1) > N/2,
% K > (N/2 + 1).  This is all managed in the routine below.
fSupport.fx = unitFrequencyList(nCols) * maxFrequency(1);
fSupport.fy = unitFrequencyList(nRows) * maxFrequency(2);

return;
