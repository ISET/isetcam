function [filterSpectra, filterNames] = sensorReadColorFilters(sensor,filterFile)
%Read in color filters (special cases) for a sensor
%
%   [filterSpectra, filterNames] = sensorReadColorFilters(ISA,filterType)
%
% Return color filter spectral transmissivities and names at a sampling
% resolution consistent with the sensor properties.
%
% See also:  sensorCreate
% Example
%
% BW Imageval Consulting, LLC, 2010

%%  Match wavelength
wave  = sensorGet(sensor,'wave');
nWave = sensorGet(sensor,'nwave');

switch lower(filterFile)
    case 'xyz'
        fname = fullfile(isetRootPath,'data','human','XYZ');
    case 'rgb'
        fname = fullfile(isetRootPath,'data','sensor','colorfilters','RGB.mat');
    case 'monochrome'
        % Should update this monochrome sensor default to a more plausible
        % PD spectral responsivity.
        filterSpectra = ones(nWave,1);
        filterNames = {'w'};
        return;
    case 'cym'
        fname = fullfile(isetRootPath,'data','sensor','colorfilters','cym.mat');
    case {'grbc'}
        fname = fullfile(isetRootPath,'data','sensor','colorfilters','GRBC.mat');
    case 'stockmanabs'
        fname = fullfile(isetRootPath,'data','human','stockman.mat');
        %     case 'mousecolorfilters.mat'
        %         fname = '/home/estelle/psych221/mouseColorFilters.mat';
    otherwise
        if exist(filterFile,'file'), fname = filterFile;
        else                         fname = vcSelectDataFile('sensor','r');
        end
end

[filterSpectra,filterNames] = ieReadColorFilter(wave,fname);

return;
