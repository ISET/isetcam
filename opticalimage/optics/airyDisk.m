function val = airyDisk(thisWave, fNumber, varargin)
% Return the Airy disk radius or diameter
%
% Synopsis
%    val = airyDisk(thisWave, fNumber, varargin)
%
% Input
%   wave:     Wavelength in meters or nanometers (both OK).
%   fnumber:  Diffraction limited optics f number
%
% Optional
%   'units'     Units of the return ('um','mm','m','deg')
%   'diameter': If true, returns diameter.  Default:  false.
%   'pupil diameter' - Used for case of 'deg'
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
p.addParameter('diameter',false,@islogical);       % Return diameter or radius
p.addParameter('pupildiameter',3e-3,@isnumeric);   % Pupil diameter, 3mm

p.parse(thisWave,fNumber,varargin{:});
units = p.Results.units;

%%  Check the wavelength
if thisWave > 200
    % Assuming the wavelength was sent in nanometers
    % disp('airydisk: Assuming wavelength in nanometers');
    thisWave = thisWave*1e-9;
end

switch units
    case {'m','mm','um'}
        % Here's the formula in spatial distance
        radius = (2.44*fNumber*thisWave)/2;  % Meters
        val = radius * ieUnitScaleFactor(units);

    case {'deg'}
        % https://www.fxsolver.com/browse/formulas/Airy+disk
        val = asind(1.22*thisWave/p.Results.pupildiameter);
        
    case {'rad'}
        val = asin(1.22*thisWave/p.Results.pupildiameter);

    otherwise
        error('Unknown unit: %s\n',units);
end

if p.Results.diameter
    val = val*2;
end


end
