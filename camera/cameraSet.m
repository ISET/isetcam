function camera = cameraSet(camera,param,val,varargin)
%Set the parameters in a camera structure
%
%   camera = cameraSet(camera,param,val)
%
% Set camera parameters.  There are only a few camera parameters, per se.
% These are
%
%
% Mainly this routine is a gateway to set the parameters of the structures
% within the camera.  The 'param' variable is parsed first by seeing if it
% starts in the form
%    obj/param, or obj-param, or "obj param"
% where obj is one of the key terms, oi, optics, sensor, ip
%
% If that is not true, but param is uniquely identifiable as one of the
% parameters of the optical image, optics, sensor, or image processor, we
% figure that out and off we go.
%
% Settable parameters
% .....
%
% (c) Stanford VISTA Team

if ~exist('camera', 'var') || isempty(camera),   error('camera struct required'); end
if ~exist('param','var') || isempty(param) , error('param required');     end
if ~exist('val','var'),                      error('val required');       end

% Parse param to see if it indicates which object.
[oType,p] = ieParameterOtype(param);

% Only oType, no parameter
if isempty(p)
    switch(oType)
        case {'oi'}
            camera.oi = val;
        case {'optics'}
            camera.oi.optics = val;
        case {'sensor'}
            camera.sensor = val;
        case {'pixel'}
            camera.sensor.pixel = val;
        case {'vci','ip'}
            camera.vci = val;
        otherwise
            error('Unknown oType with empty param %s\n',oType);            
    end
    return;  % We are done.
end

% oType and p both found
% We have to handle the varargin case, too, before long.
% For now, we just force people to do the sets/gets on the objects
% separately, not through camera.
switch oType
    % These are the main cases
    case {'oi'}
        camera.oi = oiSet(camera.oi,p,val);
    case {'optics'}
        camera.oi.optics = opticsSet(camera.oi.optics,p,val);
    case {'sensor'}
        camera.sensor = sensorSet(camera.sensor,p,val);
    case {'pixel'}
        camera.sensor.pixel = pixelSet(camera.sensor.pixel,p,val);
    case {'ip'}
        camera.vci = ipSet(camera.vci,p,val);
        
    otherwise
        % oType is probably empty or camera.  This is probably a camera parameter        
        switch ieParamFormat(param)
            
            % Book-keeping
            case {'name'}
                camera.name = val;
            case {'type'}
                camera.type = val;
                               
            
            % These are special cases for L3 camera conditions
            case {'l3sensorsize'}
                % cameraSet(camera,'L3 sensor size',sz)
                % Adjust size of sensor in camera
                sensor = cameraGet(camera,'sensor');
                sensor = sensorSet(sensor,'size',val);
                camera = cameraSet(camera,'sensor',sensor);
                
                % IMPORTANT.  I GUESS THIS HAS TO GO INTO SENSORSET.
                % Adjust size of design sensor used by L3 (which is stored in vci)
                % to match the camera sensor.
                if strcmpi(cameraGet(camera,'vci type'),'l3')
                    vci      = cameraGet(camera,'vci');
                    L3       = ipGet(vci,'L3');
                    sensorD  = L3Get(L3,'design sensor');
                    sensorD  = sensorSet(sensorD,'size',val);
                    L3       = L3Set(L3,'design sensor',sensorD);
                    vci      = ipSet(vci,'L3',L3);
                    camera   = cameraSet(camera,'vci',vci);
                end
                
            case {'l3sensorfov'}
                % cameraSet(camera,'L3 sensor fov',newFOV)
                % Adjust the size of the sensor to match a fov
                % We assume the scene is far away and the sensor is at the focal
                % length of the optics.
                sensor = cameraGet(camera,'sensor');
                sensor = sensorSetSizeToFOV(sensor,val,camera.oi);
                camera = cameraSet(camera,'sensor',sensor);
                
                % IMPORTANT.  I GUESS THIS HAS TO GO INTO SENSORSET.
                % Adjust size of design sensor used by L3 to match the camera
                % sensor field of view.
                if strcmpi(cameraGet(camera,'vci type'),'l3')
                    vci      = cameraGet(camera,'vci');
                    L3       = ipGet(vci,'L3');
                    sensorD  = L3Get(L3,'design sensor');
                    sensorD  = sensorSetSizeToFOV(sensorD,val,camera.oi);
                    L3       = L3Set(L3,'design sensor',sensorD);
                    vci      = ipSet(vci,'L3',L3);
                    camera   = cameraSet(camera,'vci',vci);
                end
                
                % cameraSet(camera, 'metric', val, metricname)
                % val is a structure that is obtained from:
                % val = cameraGet(camera, 'metric', metricname);
            case{'metric', 'metrics'}
                if isempty(varargin)        % if there is no 2nd argument
                    error('Name of metric is required as last input.')
                else
                    metricname = ieParamFormat(varargin{1});
                    if ~isfield(camera, 'metrics')
                        metrics = [];
                    else
                        metrics = camera.metrics;
                    end
                    metrics = setfield(metrics, metricname, val);
                    camera.metrics = metrics;
                end
                
            otherwise
                error('Unknown camera parameter: %s\n',param);
        end
end

end
