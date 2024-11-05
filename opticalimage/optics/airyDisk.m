function [radius,img] = airyDisk(thisWave, fNumber, varargin)
% Return the Airy disk radius (or diameter) and possibly the image
%
% Synopsis
%    [radius,img] = airyDisk(thisWave, fNumber, varargin)
%
% Input
%   wave:     Wavelength in meters or nanometers (both OK).
%   fnumber:  Diffraction limited optics f-number (empty for pinhole)
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
% Description
%    When the calculation is for an ideal lens, then the wavelength
%    and fNumber are sent in and that is all we require.
% 
%    If the calculation is for a pure pinhole, without a known
%    distance to the image plane, we calculate the angle of the rays
%    emerging from the pinhole.  In that case we expect the fNumber to
%    be empty (fNumber = []) and the units must be either 'deg' or
%    'rad'.
%
% See also
%   v_opticsWVFchromatic, s_opticsDLPSF

% Examples:
%{
thisWave = 400; fn = 2;
radius = airyDisk(thisWave,fn,'units','um')
%}
%{
thisWave = 400; fn = 8;   % Longer wavelength
[radius,img] = airyDisk(thisWave,fn,'units','um');
ieNewGraphWin; mesh(img.x,img.y,img.data);
%}
%{
thisWave = 700; fn = 8;   % Longer wavelength
[radius,img] = airyDisk(thisWave,fn,'units','um');
ieNewGraphWin; mesh(img.x,img.y,img.data);
%}
%{
thisWave = 700; fn = [];   % Decreasing pinhole size, radius gets
                           % bigger
radiusD = airyDisk(thisWave,fn,'units','deg','pupil diameter',1e-3)
radiusD = airyDisk(thisWave,fn,'units','deg','pupil diameter',1e-4)
radiusD = airyDisk(thisWave,fn,'units','deg','pupil diameter',1e-5)
%}

%%  
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisWave',@isscalar);
p.addRequired('fNumber',@(x)(isscalar(x) || isempty(x)));
p.addParameter('units','m',@ischar);
p.addParameter('diameter',false,@islogical);       % Return diameter or radius
p.addParameter('pupildiameter',3e-3,@isnumeric);   % Pupil diameter, 3mm

p.parse(thisWave,fNumber,varargin{:});
units = p.Results.units;

if isempty(fNumber)
    assert((isequal(units,'deg') || isequal(units,'rad')));
end

%%  Check the wavelength
if thisWave > 200
    % Assuming the wavelength was sent in nanometers.  Converting here
    % to meters.
    %
    % disp('airydisk: Assuming wavelength in nanometers');
    thisWave = thisWave*1e-9;
end

switch units
    case {'m','mm','um'}
        % Here's the formula in spatial units for an ideal lens and
        % a known f-number
        radius = (1.22*fNumber*thisWave);  % Meters
        radius = radius * ieUnitScaleFactor(units);

    % If we only know the pupil size, but not the distance to the
    % image plane, we calculate the angle of the bundle of rays
    % emerging from the pupil.
    case {'deg'}
        radius = asind(1.22*thisWave/p.Results.pupildiameter);
        
    case {'rad'} % radians
        radius = asin(1.22*thisWave/p.Results.pupildiameter);

    otherwise
        error('Unknown unit: %s\n',units);
end

if p.Results.diameter
    radius = radius*2;
end

if nargout == 2
    % Return the image as well.  High resolution. We can only do this
    % if we have an fNumber.  Otherwise we do not know the distance to
    % the image plane.
    if isempty(fNumber)
        warning('Cannot compute the image');
        img = []; return;
    end
    oi = oiCreate('wvf');
    oi = oiSet(oi,'wave',thisWave);
    fLength = oiGet(oi,'wvf','focal length','mm');

    % Diameter parameter is in MM
    oi = oiSet(oi,'wvf calc pupil diameter',fLength/fNumber);
    
    uData = oiPlot(oi,'psf',[],thisWave,'nofigure');
    img.data = uData.psf; img.x = uData.x(1,:); img.y = uData.y(:,1);   
    % ieNewGraphWin; mesh(img.x,img.y,img.data);
end
