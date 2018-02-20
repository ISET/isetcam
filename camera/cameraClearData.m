function camera = cameraClearData(camera)
% Clear the data fields from the camera structure
%
%   camera = cameraClearData(camera)
%
% Calls oiClearData, sensorClearData, and L3ClearData
%
% Copyright Imageval Consulting, 2015

if ieNotDefined('camera'), error('Camera required.'); end

oi     = oiClearData(cameraGet(camera,'oi'));
sensor = sensorClearData(cameraGet(camera,'sensor'));
ip     = ipClearData(cameraGet(camera,'ip'));
L3     = L3ClearData(cameraGet(camera,'ip L3'));

camera = cameraSet(camera,'oi',oi);
camera = cameraSet(camera,'sensor',sensor);
camera = cameraSet(camera,'ip',ip);
camera = cameraSet(camera,'ip L3',L3);

end
