function [data, newFilterNames, fileData] = ieReadColorFilter(wave, fname)
%Read transmission data and names for a set of color filters
%
%   [data,newFilterNames,fileData] = ieReadColorFilter(wave,fname);
%
% The color filter information includes the wavelength tranmission curve
% and color filter names.  The filter curves are a special case of
% reading spectral data fo two reaons.  (a) The use of filter names, (b)
% the requirement that the transmission values run between 0 and 1.
% These requirements lead to a special function, different from the more
% commonly used function, ieReadSpectral().
%
% If values exceed 1, the data are scaled.  If values are below 0, the
% user is asked to adjust the data.
%
% If the user presses Cancel in the uigetfile interface, the returned
% variables are set to null.
%
% In some cases, users add additional data to the file for user-defined
% reasons.  All of the variables in the data file are returned in the
% third variable, the data structure called fileData.
%
% Example:
%    isa = sensorCreate;
%    wave = sensorGet(isa,'wave');
%    [data,newFilterNames] = ieReadColorFilter(wave);
%    plot(wave,data);
%
%   [data,newFilterNames] = ieReadColorFilter(wave,'G');
%
%   [data,newFilterNames,allData] = ieReadColorFilter(wave,'G');
%
% See also:  ieSaveColorFilter
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('wave'), wave = 400:10:700; end
if ieNotDefined('fname')
    fname = vcSelectDataFile('sensor');
    if isempty(fname), data = [];
        newFilterNames = [];
        return;
    end
end

% Read the spectral data at the requested wavelength resolution
data = ieReadSpectra(fname, wave);
if isempty(data)
    error('Cannot find %s\n', fname);
elseif ((max(data(:)) > 1) || (min(data(:)) < 0))
    if min(data(:)) >= 0
        questdlg('Data values greater than 1. Scaling data to a maximum of 1.', 'Read Data', 'OK', 'OK');
        data = ieScale(data, 1);
    else
        errordlg('Data values less than 0. Adjust the data file.');
    end
end

% If there are filter names, return them.  This is a cell array describing
% each column of data.  The first character is from the list in
% sensorColorOrder, rgbcmyw.  We could/should check (enforce) this here.
if nargout >= 2
    fileData = load(fname);
    if checkfields(fileData, 'filterNames')
        newFilterNames = fileData.filterNames;
    else
        warndlg(sprintf('No filter names found in file %s.', fname));
        newFilterNames = [];
    end
end

% It may be that there are 3 output arguments.  In that case, the third is
% simply the entire structure of data returned by reading the file.  This
% structure can contain auxiliary data, saved by ieSaveColorFilter, that
% the user might have tucked into the file.

return;