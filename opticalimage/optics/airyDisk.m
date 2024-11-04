function [radius,img] = airyDisk(thisWave, fNumber, varargin)
% Return the Airy disk radius (or diameter) and possibly the image
%
% Synopsis
%    [radius,img] = airyDisk(thisWave, fNumber, varargin)
%
% Input
%   wave:     Wavelength in meters or nanometers (both OK).
%   fnumber:  Diffraction limited optics f number
%
% Optional
%   'units'     Units of the return ('um','mm','m','deg') default: 'm'
%   'diameter': If true, returns diameter.  Default:  false.
%   'pupil diameter' - Used for case of 'deg'
%
% Return
%   radius:  Radius (default) or if diameter is set to true then
%            diameter.
%   img:     Struct with an image of the Airy pattern as well as the x and
%            y values
%
% See also
%   v_opticsWVFchromatic, s_opticsDLPSF

% Examples:
%{
thisWave = 400; fn = 5;
radius = airyDisk(thisWave,fn,'units','um')
%}
%{
thisWave = 700; fn = 5;   % Longer wavelength
[~,img] = airyDisk(thisWave,fn,'units','um');
ieNewGraphWin; mesh(img.x,img.y,img.data);
%}
%{
thisWave = 700; fn = 2;   % Bigger aperture
radius = airyDisk(thisWave,fn)
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
        radius = radius * ieUnitScaleFactor(units);

    case {'deg'}
        % https://www.fxsolver.com/browse/formulas/Airy+disk
        radius = asind(1.22*thisWave/p.Results.pupildiameter);
        
    case {'rad'}
        radius = asin(1.22*thisWave/p.Results.pupildiameter);

    otherwise
        error('Unknown unit: %s\n',units);
end

if p.Results.diameter
    radius = radius*2;
end

if nargout == 2
    % Return the image as well
    oi = oiCreate('wvf');
    oi = oiSet(oi,'fnumber',fNumber);
    thisWave = 400;
    uData = oiPlot(oi,'psf',[],thisWave,'nofigure');
    img.data = uData.psf; img.x = uData.x(1,:); img.y = uData.y(:,1);
    % ieNewGraphWin; mesh(img.x,img.y,img.data);
end
