function sensor = sensorReadFilter(filterType,sensor,fname)
%Read color filter transmissivities of various sorts
%
%   sensor = sensorReadFilter(filterType,sensor,fname)
%
% Read and set the sensor color filter transmissivity.  The files are
% filter spectra as saved by ieSaveColorFilter.  These files have variables
% with specific names, wavelength, and transmissivities. Some also have a
% pattern for the CFA structure.  We think of these as cfa file.
%
% Data defining color filters, the photodector spectral quantum efficiency,
% infrared cutoff filter, and the color filter array, can all be read by
% this program.  The difference is which slot they are put into in the
% sensor structure.
%
% Resetting any of these curves in the sensor changes the currently the
% properties of the image sensor array and should clear the sensor data.
% This happens on the return in sensorWindow.
%
% The wavelength sampling of the data matches the current specification in
% sensor.
%
% Inputs
%  filterType: a string: cfa, pdspectralqe, infrared, colorfilters
%  sensor - sensor structure
%  fname  - filter file name
% Return
%   The sensor is with the updated fields is returned
%
% See also:  Used in sensorWindow:
%
% Copyright Imageval Consulting, LLC 2005

if ieNotDefined('sensor'), sensor = ieGetObject('ISA'); end
if ieNotDefined('filterType'), filterType = 'cfa'; end

% Read the color filter data, matched to sensor
if ieNotDefined('fname')
    % Read the color filter data
    fname = vcSelectDataFile(fullfile(isetRootPath,'data','sensor','cfa'));
    if isempty(fname),  return; end
end

% Read the filter transmission spectra
wavelength = sensorGet(sensor, 'wave');
%{
load(fname,'wavelength');
sensor = sensorSet(sensor,'wave',wavelength);
%}
[filterSpectra,newFilterNames,extra] = ieReadColorFilter(wavelength,fname);
if isempty(filterSpectra), error('No filter spectra'); end

switch lower(filterType)
    case 'cfa'
        % A cfa is a color filter file that has an extra 'pattern' slot in
        % the structure.  Not all of them do, so ...
        if ~isfield(extra,'pattern'), pattern = sensorGet(sensor,'pattern');
        else                          pattern = extra.pattern;
        end
        nCols = size(filterSpectra,2);
        pattern = min(nCols,pattern);
        
        % Assign the data
        sensor = sensorSet(sensor,'filterspectra',filterSpectra);
        sensor = sensorSet(sensor,'filternames',newFilterNames);
        sensor = sensorSet(sensor,'pattern',pattern);
    case 'pdspectralqe'
        sensor = sensorSet(sensor,'pixel pd spectral qe',filterSpectra);
        
    case {'infrared','irfilter'}
        sensor = sensorSet(sensor,'infrared',filterSpectra);
        
    case {'colorfilters','colorfilter'}
        % Replace, but pattern entries must not exceed number of filters
        pattern = sensorGet(sensor,'pattern');
        nCols = size(filterSpectra,2);
        pattern = min(nCols,pattern);
        
        % Assign the data
        sensor = sensorSet(sensor,'filterspectra',filterSpectra);
        sensor = sensorSet(sensor,'filternames',newFilterNames);
        sensor = sensorSet(sensor,'pattern',pattern);
        
    otherwise
        error('Unknown color type.');
end

end
