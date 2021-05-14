function ml = mlensCreate(sensor,oi)
% Create a default microlens array structure
%
%   ml = mlensCreate([sensor],[oi])
%
% The microlens parameters are set using the sensor and oi/optics.  If
% these are not sent in, the currently selected sensor and oi in the ISET
% database. are used.  Not sure this is a good idea.
%
%Example:
%    ml = mlensCreate;
%
% Copyright Imageval, LLC 2005

if ieNotDefined('sensor'),
    sensor = vcGetObject('sensor');
    if isempty(sensor),
        sensor = sensorCreate; ieAddObject(sensor);
    end
    fprintf('** Using current ISET sensor %s\n',sensorGet(sensor,'name'));
end

if ieNotDefined('oi'),
    oi = vcGetObject('oi');
    if isempty(oi),
        oi = oiCreate; ieAddObject(oi);
    end
    fprintf('** Using current ISET oi %s\n',oiGet(oi,'name'));
end

ml.name = 'default';
ml.type = 'microlens';

ml.rayAngle   = 0;      %In degrees
ml.wavelength = 500;    %In nanometers

optics = oiGet(oi,'optics');
pixel  = sensorGet(sensor,'pixel');
ml     = mlImportParams(ml,optics,pixel);

ml.offset = 0;              % Microns, should change to meters
ml.refractiveIndex = 1.5;   % Might call this 'n' before too long

return;
