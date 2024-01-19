function conePsfInfo = conePsfInfoCreate(varargin)
% Return a structure with cone PSf information
%
% Syntax:
%   onePsfInfo = conePsfInfoCreate
%
% Description:
%    Return a structure with cone PSF inforamtion. This structure contains
%    cone spectral sensitivities and a spectral weighting function that are
%    used to estimate the PSF seen by each class of cones.
%
%    It also contains a weight vector, that specifies how optical quality
%    measures should be averaged across cone classes into an omnibus
%    measured of optical quality. This is useful for calculations that, for
%    example, try to optimize accommodation to maximize optical quality.
%
%    If you pass spectral sensitivities and/or spectral weighting, you must
%    make sure that they are on the same wavelength sampling as the
%    specified wavelengths.
%
% Inputs:
%    None
%
% Output
%    conePsfInfo - The cone PSF information structure.
%
% Optional key/value pairs:
%    'wavelengths'           - Column vector of wavelengths. Default
%                              (400:10:700)'.
%    'spectralSensitivities' - Matrix of cone spectral sensitivities in
%                              energy units. These are in the rows of a
%                              matrix whose columns correspond to
%                              wavelength samples. Default, 
%                              Stockman-Sharpe 2 degree.
%    'spectralWeighting'     - Spectral weighting vector, in a column
%                              vector that sums to 1. Default, equal
%                              weighting.
%    'coneWeighting'         - Cone weighting vector, in a column vector
%                              with one entry per cone class which sums to
%                              1. Default, equal weighting.
%
% See Also:
%    conePsfInfoGet, conePsfInfoSet, wvfComputeOptizedConePSF
%

% History:
%    01/15/18  dhb  Wrote this.
%    01/18/18  jnm  Formatting

% Examples:
%{
    conePsfInfo = conePsfInfoCreate
%}

%% Setup parser, massage varargin and parse
p = inputParser;
p.addParameter('wavelengths', (400:10:700)', @isnumeric);
p.addParameter('spectralSensitivities', [], @isnumeric);
p.addParameter('spectralWeighting', [], @isnumeric);
p.addParameter('coneWeighting', [], @isnumeric);
ieVarargin = ieParamFormat(varargin);
p.parse(ieVarargin{:});

%% Set wavelengths 
conePsfInfo.wavelengths = p.Results.wavelengths;

% Cone sensitivities
if (~isempty(p.Results.spectralSensitivities))
    if (size(p.Results.spectralSensitivities, 2) ~= ...
            length(conePsfInfo.wavelengths))
        error(['Specified spectral sensitivity wavelength sampling', ...
              ' not consistent with specified wavelength sampling']);
    end
    conePsfInfo.spectralSensitivities = p.Results.spectralSensitivities;
else
    temp = load('conesPsfInfoData_ss2');
    conePsfInfo.spectralSensitivities = SplineCmf(temp.S_cones_ss2, ...
        temp.T_cones_ss2, conePsfInfo.wavelengths);
    clear temp    
end

% Weighting spectrum
if (~isempty(p.Results.spectralWeighting))
    if (length(p.Results.spectralWeighting) ~= ...
            length(conePsfInfo.wavelengths))
        error(['Specified spectral weighting', ...
              ' not consistent with specified wavelength sampling']);
    end
    conePsfInfo.spectralWeigting = p.Results.spectralWeighting;
else
    conePsfInfo.spectralWeighting = ones(size(conePsfInfo.wavelengths));
    conePsfInfo.spectralWeighting = ...
        conePsfInfo.spectralWeighting / sum(conePsfInfo.spectralWeighting); 
end

% Weighting spectrum
if (~isempty(p.Results.coneWeighting))
    if (length(p.Results.coneWeighting) ~= ...
            size(conePsfInfo.spectralSensivities, 1))
        error(['Specified cone weighting', ...
              ' not consistent with number of cone classes']);
    end
    conePsfInfo.coneWeighting = p.Results.coneWeighting;
else
    conePsfInfo.coneWeighting = ones(size(...
        conePsfInfo.spectralSensitivities, 1), 1);
    conePsfInfo.coneWeighting = ...
        conePsfInfo.coneWeighting / sum(conePsfInfo.coneWeighting); 
end
