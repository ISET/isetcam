function obj = cameraWindow(camera,oType)
% Open a window showing some of the camera object components
%
% Synopsis
%   obj = cameraWindow(camera,oType)
%
% Inputs:
%   camera
%   oType
%
% Return:
%   obj:
%
% Description
%  The camera structure contains the optical image, sensor, and ip
%  structures. This routine adds the specified camera object to its
%  corresponding window and then opens and selects that object in the
%  window.
%
%  The figure number and selected object can be returned. In the case of
%  choosing oType = 'all', hdl and obj are cell arrays with three window
%  handles and objects.
%
% Examples:
%   camera = cameraCreate; scene = sceneCreate;
%   camera = cameraCompute(camera,scene);
%
%   cameraWindow(camera);          % Opens ip window
%   cameraWindow(camera,'oi');     % Opens optical image window
%   cameraWindow(camera,'sensor'); % Sensor window
%
% See also:  cameraGet, cameraSet, cameraCreate
%
% (c) Imageval Consulting, LLC 2014


%% Arguments
if ieNotDefined('camera'), error('Camera object required'); end
if ieNotDefined('oType'), oType = 'ip'; end

%% Main switch for opening window

oType = ieParamFormat(oType);

switch oType
    case {'oi','opticalimage'}
        obj = cameraGet(camera,'oi');
        oiWindow(obj);
        
    case {'sensor','isa'}
        obj = cameraGet(camera,'sensor');
        sensorWindow(obj);
        
    case {'ip','vci','vcimage'}
        obj = cameraGet(camera,'ip');
        ipWindow(obj);
        
    otherwise
        error('Unknown object type %s\n',oType);
end

end