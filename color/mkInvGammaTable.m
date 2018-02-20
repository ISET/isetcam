function result = mkInvGammaTable(gTable,numEntries)
% Compute inverse gamma lookup table (intensity to digital control value)
%
%    result = mkInvGammaTable(gTable,numEntries)
%
%PURPOSE:
%  A (display) gamma table maps digital control values to display
%  intensity.  Don't let anyone tell you different.   The gamma table of a
%  display is usually measured empirically or approximated by a simple rule
%  I = d^g + b.
%
%  To render linear intensity images on a display, requires the inverse of
%  a gamma table. The inverse gamma table takes linear intensity levels as
%  input and returns device-dependent digital control values as output.
%
%  The table must be monotonic (or else the inverse doesn't exist). For
%  precision, inverse gamma tables are usually defined at a finer scale of
%  intensities than the number of steps in the gamma table.  The parameter
%  numEntries specifies the number of entries in the inverse table.
%
%  In some cases, measurement noise produces non-monotonicities in a gamma
%  table. This can happen, in particular, at low intensities. On the
%  assumption  that non-monotonicities are meaningless, this routine sorts
%  non-monotonic tables and warn the user. 
%
%  gTable:      Gamma table from frame-buffer to linear intensity
%  numEntries:  Number of sample values in the inverse table
%  result:      Inverse gamma table that maps from linear intensity to
%	           frame-buffer value.
%
%Example:
% load('displayGamma','gamma');    % This loads a gamma table
% invGamma = mkInvGammaTable(gamma,4*size(gamma,1));
% 
% Test whether the tables are proper inverses.  Make some linear intensity
% values.
%
% light = rand(5,3);
% digital = rgb2dac(light,invGamma);
% light2 = dac2rgb(digital,gamma);
% percentError = 100* (light2 - light) ./ light
%
% If we repeat the process, we avoid the imperfections of the discrete set
% of look up table levels. The inversion is then perfect.  
%
% digital2 = rgb2dac(light2,invGamma)
% light3 = dac2rgb(digital2,gamma)
% light3 - light2
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('gTable'), error('Gamma table required.'); end
if ieNotDefined('numEntries'), numEntries = 4*size(gTable,1); end

ncol = size(gTable,2);
result = zeros(numEntries,ncol);

%  Check for monotonicity, and fix if not monotone
for ii=1:ncol

 thisTable = gTable(:,ii);

% Find the locations where this table is not monotonic
 list = find(diff(thisTable) <= 0);

 if length(list) > 0
  announce = sprintf('Gamma table %d NOT MONOTONIC.  We are adjusting.',ii);
  disp(announce)

% We assume that the non-monotonic points only differ due to noise
% and so we can resort them without any consequences
%
  thisTable = sort(thisTable);

% Find the sorted locations that are actually increasing.
% In a sequence of [ 1 1 2 ] the diff operation returns the location 2
%
  posLocs = find(diff(thisTable) > 0);

% We now shift these up and add in the first location
%
  posLocs = [1; (posLocs + 1)];
  monTable = thisTable(posLocs,:);

 else

% If we were monotonic, then yea!
  monTable = thisTable;
  posLocs = 1:size(thisTable,1);
 end

% Interpolate the monotone table out to the proper size
%
 result(:,ii) = ...
   reshape( ...
   interp1(monTable,posLocs-1,[0:(numEntries-1)]/(numEntries-1)),...
   numEntries,1); 

end

return;
