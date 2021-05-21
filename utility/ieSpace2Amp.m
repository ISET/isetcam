function [freq,fData] = ieSpace2Amp(pos,data,scaleData)
% Transform spatial data to amplitudes in cycles per spatial unit
%
%   [freq,fData] = ieSpace2Amp(pos,data,scaleData)
%
%   pos:  Positions in spatial units (e.g., microns)
%   data: vector of data values for each spatial position
%
% The returned amplitudes are abs(fft(data)) of the data vector.  The
% spatial frequency value units are in cycles per unit of the input data.
% For example, if the input data are in mm, then the output data are in
% cycles per mm.  If the input data are in meters, then the output is
% cycles per meter
%
% See also:  scenePlot, plotOI, sensorPlotLine
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('pos'),  errordlg('You must define positions'); end
if ieNotDefined('data'), errordlg('You must define a vector of data'); end
if ieNotDefined('scaleData'), scaleData = 0; end

nSamp = length(data);
fData = abs(fft(data));

% Scale the data to a peak of 1 before analyzing.  Was default.  Unh oh.
% Keep an eye on what has changed.
if scaleData, fData = fData/max(fData(:)); end

% This is the units per image
unitPerImage = (max(pos) - min(pos));

% The frequency values are scaled into units. Without scaling the frequency
% representation is cycles / image (or cycle/data set).  With this
% correction we have
%    cycle/image / (unit/image) = cycle/unit
% In addition, the true frequency numbers range from 0 (mean) on up, and
% there are only half as many (Nyquist) as there are samples.
freq = ((1:nSamp) - 1)/unitPerImage;
nFreq = round((nSamp - 1)/2);

% Here are the frequency data from the mean up to the Nyquist frequency.
fData = fData(1:nFreq);
freq = freq(1:nFreq);

return;