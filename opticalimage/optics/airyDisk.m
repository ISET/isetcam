function val = airyDisk(thisWave, fNumber, varargin)
% Return the Airy disk radius or diameter
%
% Input
%   wave:     Wavelength in meters or nanometers (both OK).
%   fnumber:  Diffraction limited optics f number
%
% Optional
%   'units'     Units of the return ('um','mm','m')
%   'diameter': If true, returns diameter.  Default:  false.
%
% Return
%   val:   Radius (default) or if diameter is set to true then
%          diameter.
%
% See also
%   v_opticsWVFchromatic, s_opticsDLPSF

% Examples
%{
thisWave = 400; fn = 5;
radius = airyDiskRadius(thisWave,fn,'units','um')
   
thisWave = 700; fn = 5;   % Longer wavelength
radius = airyDiskRadius(thisWave,fn,'units','um')

thisWave = 700; fn = 2;   % Bigger aperture
radius = airyDiskRadius(thisWave,fn,'units','um')
%}

%%  
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisWave',@isscalar);
p.addRequired('fNumber',@isscalar);
p.addParameter('units','m',@ischar);
p.addParameter('diameter',false,@islogical);

p.parse(thisWave,fNumber,varargin{:});
units = p.Results.units;

%%  Check the wavelength
if thisWave > 100
    % Assuming the wavelength was sent in nanometers
    disp('Assuming wavelength in nanometers');
    thisWave = thisWave*1e-9;
end

% Here's the formula
radius = (2.44*fNumber*thisWave)/2;  % Meters

if exist('units','var')
    val = radius * ieUnitScaleFactor(units);
end

if p.Results.diameter
    val = val*2;
end


end
