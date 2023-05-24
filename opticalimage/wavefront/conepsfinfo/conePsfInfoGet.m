function val = conePsfInfoGet(conePsfInfo, parm, varargin)
% Get function for cone psf information parameters
%
% Syntax:
%   val = conePsfInfoGet(conePsfInfo, parm)
%
% Description:
%    The get function for the cone psf information parameters
%
%    Examples are included in the source code.
%
% Inputs:
%    conePsfInfo - The cone PSF information structure.
%    parm        - The desired parameter's name. The options are:
%         'wavelengths'           - Column vector of wavelengths.
%         'spectralSensitivities' - Matrix of cone spectral sensitivities
%                                   in energy units. These are in the rows
%                                   of a matrix whose columns correspond
%                                   to wavelength samples.
%         'spectralWeighting'     - Spectral weighting vector, in a column
%                                   vector that sums to 1.
%         'coneWeighting'         - Cone weighting vector, in a column
%                                   vector with one entry per cone class
%                                   that sums to 1.
%
% Outputs:
%    val         - The value of the desired parameter.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    conePsfInfoCreate, conePsfInfoSet, wvfComputeOptizedConePSF
%

% History:
%    01/15/18  dhb  Wrote this.
%    01/18/18  jnm  Formatting

% Examples:
%{
    conePsfInfo = conePsfInfoCreate;
    wls = conePsfInfoGet(conePsfInfo, 'wavelengths');
    T = conePsfInfoGet(conePsfInfo, 'spectralSensitivities');
    figure;
    clf;
    hold on
    plot(wls, T');

    conePsfInfoGet(conePsfInfo, 'spectralWeighting')'
    conePsfInfoGet(conePsfInfo, 'coneWeighting')'
%}

% Default is empty when the parameter is not yet defined.
parm = ieParamFormat(parm);

% Do what needs to be done
switch parm
    case 'wavelengths'
        val = conePsfInfo.wavelengths;
    case 'spectralsensitivities'
        val = conePsfInfo.spectralSensitivities;
    case 'spectralweighting'
        val = conePsfInfo.spectralWeighting;
        val = val / sum(val);
    case 'coneweighting'
        val = conePsfInfo.coneWeighting;
        val = val / sum(val);   
    otherwise
        error('Unknown parameter %s\n', parm);
end

end
