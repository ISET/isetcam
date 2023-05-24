function keyValues = wvfKeySynonyms(keyValues)
% Convert cell array of key value pairs to canonical form
%
% Syntax:
%   keyValues = wvfKeySynonyms(keyValues)
%
% Description:
%   Check a passed string, or each string in the odd entries of a passed
%   string cell array, and convert each to the canonical form understood by
%   the wvf code.
%
%   Typical usage would be to pass varargin through this, resulting in a
%   cell array of strings that could be passed to the input parser, where
%   the input parser understood only one of each set of synonyms.
%
%   The other usage would be to pass the parm value for wvfSet/wvfGet
%   through this.
%
%   Use of this function encapsulates all of the synonyms we accept, and
%   makes sure they are used consistently across the wvf functions.
%
% Inputs:
%   keyValues - single string a cell array of strings.  The single string
%               or the odd entries of the cell array converted.
%
% Outputs:
%   KeyValues - string or a cell array of strings, after conversion.
%               Output format matches input format.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%  ieParamFormat, wvfCreate, wvfGet, wvfSet

% History:
%	 12/07/17  dhb  Wrote.
%    01/10/18  jnm  Formatting update

%% Handle case where a single string is passed
%
% This converts input into a cell array. We reconvert after the synonym
% replacement section.
if (ischar(keyValues))
    keyValuesCell = {keyValues};
elseif (iscell(keyValues))
    keyValuesCell = keyValues;
else
    error('Input must be a string or a cell array of strings');
end

%% Loop over keys and convert each according to synoyms
for kk = 1:2:length(keyValuesCell)
    switch (keyValuesCell{kk})
        case {'name'}
            keyValuesCell{kk} = 'name';
        case {'type'}
            keyValuesCell{kk} = 'type';
        case {'umperdegree'}
            keyValuesCell{kk} = 'umperdegree';
        case {'zcoeffs', 'zcoeff', 'zcoef'}
            keyValuesCell{kk} = 'zcoeffs';
        case {'wavefrontaberrations'}
            keyValuesCell{kk} = 'wavefrontaberrations';
        case {'pupilfunction', 'pupilfunc', 'pupfun'}
            keyValuesCell{kk} = 'pupilfunction';
        case {'measuredpupilsize', 'measuredpupil', 'measuredpupilmm', ...
                'measuredpupildiameter'}
            keyValuesCell{kk} = 'measuredpupil';
        case {'measuredwave', 'measuredwl', 'measuredwavelength'}
            keyValuesCell{kk} = 'measuredwl';
        case {'measuredopticalaxis', 'measuredopticalaxisdeg'}
            keyValuesCell{kk} = 'measuredopticalaxis';
        case {'measuredobserveraccommodation', ...
                'measuredobserveraccommodationdiopters'}
            keyValuesCell{kk} = 'measuredobserveraccommodation';
        case {'measuredobserverfocuscorrection', ...
                'measuredobserverfocuscorrectiondiopters'}
            keyValuesCell{kk} = 'measuredobserverfocuscorrection';
        case {'zcoeffs', 'zcoeff', 'zcoef'}
            keyValuesCell{kk} = 'zcoeffs';
        case {'sampleintervaldomain'}
            keyValuesCell{kk} = 'sampleintervaldomain';
        case {'numberspatialsamples', 'spatialsamples', 'npixels', ...
                'fieldsizepixels'}
            keyValuesCell{kk} = 'spatialsamples';
        case {'refpupilplanesize', 'refpupilplanesizemm', 'fieldsizemm'}
            keyValuesCell{kk} = 'refpupilplanesize';
        case {'refpupilplanesampleinterval', 'fieldsamplesize', ...
                'refpupilplanesampleintervalmm', ...
                'fieldsamplesizemmperpixel'}
            keyValuesCell{kk} = 'refpupilplanesampleinterval';
        case {'refpsfsampleinterval' 'refpsfarcminpersample', ...
                'refpsfarcminperpixel'}
            keyValuesCell{kk} = 'refpsfsampleinterval';
        case {'calcpupilsize', 'calcpupildiameter', 'calculatedpupil', ...
                'calculatedpupildiameter'}
            keyValuesCell{kk} = 'calcpupilsize';
        case {'calcopticalaxis'}
            keyValuesCell{kk} = 'calcopticalaxis';
        case {'calcobserveraccommodation'}
            keyValuesCell{kk} = 'calcobserveraccommodation';
        case {'calcobserverfocuscorrection', 'defocusdiopters'}
            keyValuesCell{kk} = 'calcobserverfocuscorrection';
        case {'calcwave', 'calcwavelengths', 'wavelengths', ...
                'wavelength', 'wls', 'wave'}
            keyValuesCell{kk} = 'calcwavelengths';
        case {'calcconepsfinfo'}
            keyValuesCell{kk} = 'calcconepsfinfo';
        case {'sceparams', 'stilescrawford'}
            keyValuesCell{kk} = 'sceparams';
    end
end

%% Handle case where a single string is passed
if (ischar(keyValues))
    keyValues = keyValuesCell{1};
elseif (iscell(keyValuesCell))
    keyValues = keyValuesCell;
end