function conePsfInfo = conePsfInfoSet(conePsfInfo, parm, val, varargin)
% Set function for cone psf information parameters
%
% Syntax:
%   conePsfInfo = conePsfInfoSet(conePsfInfo, parm, val)
%
% Description:
%    The get function for the cone psf information parameters.
%
% Inputs:
%    conePsfInfo - The cone PSF information structure.
%    parm        - The desired parameter's name. The options are:
%        'wavelengths'           - Column vector of wavelengths. This
%                                  will spline exant spectral
%                                  sensitivities and weighting on set.
%        'spectralSensitivities' - Matrix of cone spectral sensitivities
%                                  in energy units. These are in the
%                                  rows of a matrix whose columns
%                                  correspond to wavelength samples.
%                                  Spectral sampling must match that
%                                  specified by wavelengths.
%        'spectralWeighting'     - Spectral weighting vector, in a column
%                                  vector that sums to 1. This will do the
%                                  normalization on set, if it isn't
%                                  already normalized. Spectral sampling
%                                  must match that specified by wavelengths
%        'coneWeighting'         - Cone weighting vector, in a column
%                                  vector with one entry per cone class
%                                  that sums to 1. This will do the
%                                  normalization on set, if it isn't
%                                  already normalized.
%   val          - The value of the desired parameter
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%
% Examples are included in the source code.
%
% See Also:
%    conePsfInfoCreate, conePsfInfoGet, wvfComputeOptizedConePSF
%

% History:
%    01/15/18  dhb  Wrote this.
%    01/18/18  jnm  Formatting

% Examples:
%{
    conePsfInfo = conePsfInfoCreate;
    val = conePsfInfoGet(conePsfInfo, 'spectralWeighting'); val'
    sum(val)
    val(1) = 3 * val(1);
    conePsfInfo = conePsfInfoSet(conePsfInfo, 'spectralWeighting', val);
    val = conePsfInfoGet(conePsfInfo, 'spectralWeighting');
    val'
    sum(val)
%}
%{
    conePsfInfo = conePsfInfoCreate;
    wls = conePsfInfoGet(conePsfInfo, 'wavelengths');
    T1 = conePsfInfoGet(conePsfInfo, 'spectralSensitivities');
    temp = load('T_cones_sp');
    wlsT = SToWls(temp.S_cones_sp);
    conePsfInfo = conePsfInfoSet(conePsfInfo, 'wavelengths', wlsT);
    conePsfInfo = conePsfInfoSet(conePsfInfo, 'spectralSensitivities', ...
        temp.T_cones_sp);
    wls2 = conePsfInfoGet(conePsfInfo, 'wavelengths');
    T2 = conePsfInfoGet(conePsfInfo, 'spectralSensitivities');
  
    figure; clf; hold on
    plot(wls, T1');
    plot(wls2, T2', 'k-'); 
%}

% Default is empty when the parameter is not yet defined.
parm = ieParamFormat(parm);

% Do what needs to be done
switch parm
    case 'wavelengths'
        % When changing wavelengths, spline sensitivities and weighting
        % function onto new wavelengthe sampling, and renormalize.
        if (~isempty(conePsfInfo.spectralSensitivities))
            conePsfInfo.spectralSensitivities = ...
                SplineCmf(conePsfInfo.wavelengths, ...
                conePsfInfo.spectralSensitivities, val);
            conePsfInfo.spectralSensitivities = ...
                conePsfInfo.spectralSensitivities / ...
                sum(conePsfInfo.spectralSensitivities);
        end
        if (~isempty(conePsfInfo.spectralWeighting))
            conePsfInfo.spectralWeighting = ...
                SplineSpd(conePsfInfo.wavelengths, ...
                conePsfInfo.spectralWeighting, val);
            conePsfInfo.spectralWeighting = ...
                conePsfInfo.spectralWeighting / ...
                sum(conePsfInfo.spectralWeighting);
        end
        conePsfInfo.wavelengths = val;
        
    case 'spectralsensitivities'
        % Check consistency with wavelength sampling.
        if (size(val, 2) ~= ...
                length(conePsfInfo.wavelengths))
            error(['Specified spectral sensitivity wavelength sampling' ...
                ' not consistent with specified wavelength sampling']);
        end
        conePsfInfo.spectralSensitivities = val;
        
    case 'spectralweighting'
        % Check consistency with wavelength sampling and normalize.
        if (length(val) ~= ...
                length(conePsfInfo.wavelengths))
            error(['Specified spectral weighting wavelength sampling' ...
                ' not consistent with specified wavelength sampling']);
        end
        val = val / sum(val);
        conePsfInfo.spectralWeighting = val;
        
    case 'coneweighting'
        % Check size and normalize.
        if (length(val) ~= ...
                size(conePsfInfo.spectralSensivities, 1))
            error(['Specified cone weighting', ...
                ' not consistent with number of cone classes']);
        end
        val = val / sum(val);
        conePsfInfo.coneWeighting = val;
        
    otherwise
        error('Unknown parameter %s\n', parm);
end

end
