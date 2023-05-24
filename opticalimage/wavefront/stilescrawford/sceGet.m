function val = sceGet(sceP, parm, varargin)
% Get function for Stiles-Crawford effect parameters
%
% Syntax:
%   val = sceGet(sceP, parm, [varargin])
%
% Description:
%    The get function for the Stiles-Crawford effect parameters
%
% Inputs:
%    sceP     - Stiles-Crawford Effect parameters structure
%    parm     - The desired parameter's name. The options are:
%               xo           - SCE x center in mm relative to pupil center
%               yo           - SCE y center in mm relative to pupil center
%               wave(length) - SCE wavelengths
%               rho          - SCE peakedness rho as a function of
%                              wavelength (units: 1/mm^2)
%    varargin - (Optional) Wavelength list
%
% Outputs:
%    val      - The value of the desired parameter
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    sceCreate
%

% History:
%    xx/xx/12       (c) Wavefront Toolbox Team, 2012
%    11/10/17  jnm  Formatting

% Examples:
%{
    sceP = sceCreate(550, 'berendschot_data', 'centered');
    sceGet(sceP, 'xo')
	sceGet(sceP, 'wavelengths')
	sceGet(sceP, 'rho', 550)
%}


if notDefined('sceP'), error('sceP must be defined.'); end
if notDefined('parm'), error('Parameter must be defined.'); end

% Default is empty when the parameter is not yet defined.
parm = ieParamFormat(parm);

switch parm
    case 'xo'
        val = sceP.xo;
    case 'yo'
        val = sceP.yo;
    case {'wave', 'wavelengths'}
        val = sceP.wavelengths;
    case 'rho'
        if isempty(varargin)
            val = sceP.rho;
            return
        else
            wList = varargin{1};
            [l, loc] = ismember(wList, sceP.wavelengths); %#ok<ASGLU>
            val = sceP.rho(loc);
        end
    otherwise
        error('Unknown parameter %s\n', parm);
end

end
