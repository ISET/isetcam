function [fig,obj] = cameraWindow(camera,oType)
% Open a window showing some of the camera object components
%
%   [fig, obj] = cameraWindow(camera,oType)
%
% The camera structure contains the optical image, sensor, and ip
% structures. This routine adds the specified camera object to its
% corresponding window and then opens and selects that object in the
% window.
%
% The figure number and selected object can be returned. In the case of
% choosing oType = 'all', hdl and obj are cell arrays with three window
% handles and objects.
%
% Examples:
%   camera = cameraCreate; scene = sceneCreate;
%   camera = cameraCompute(camera,scene);
%
%   cameraWindow(camera);          % Opens ip window
%   cameraWindow(camera,'oi');     % Opens optical image window
%   cameraWindow(camera,'sensor'); % Sensor window
%   cameraWindow(camera,'all');    % OI, sensor and ip windows all opened
%   cameraWindow(camera,'eTest');  % Error test
%
%   [f,oi] = cameraWindow(camera,'oi');
%   hdl = guihandles(f);
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
        ieAddObject(obj); fig = oiWindow;
        
    case {'sensor','isa'}
        obj = cameraGet(camera,'sensor');
        ieAddObject(obj); fig = sensorImageWindow;
        
    case {'ip','vci','vcimage'}
        obj = cameraGet(camera,'ip');
        ieAddObject(obj); fig = ipWindow;
        
    case {'all'}
        obj = cell(3,1);
        fig = cell(3,1);
        [fig{1}, obj{1}] = cameraWindow(camera,'oi');
        [fig{2}, obj{2}] = cameraWindow(camera,'sensor');
        [fig{3}, obj{3}] = cameraWindow(camera,'ip');
        
    otherwise
        error('Unknown object type %s\n',oType);
end

end