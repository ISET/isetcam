function camera = cameraCreate(cType,varargin)
%Create a camera object
%
% camera = cameraCreate(cType,[L3struct])
%
%   Default    - Use default oi, sensor, and ip structures
%   Current    - Collect up the currently selected oi, sensor, and ip
%                If not available, use default
%   L3         - L3 type camera based on sensors in the L3 structure
%   Ideal      - Diffraction limited, noise free sensor with XYZ
%   monochrome - A default monochrome sensor
%   
%
% Normally we create a camera from the currently selected oi, sensor, and
% ip.  If there are none selected, we use the defaults.
%
% It is also possible to create an ideal camera with a noise free (photon
% noise only from the scene) monochrome sensor.
%
% Examples:
%   c = cameraCreate;
%   c = cameraCreate('current');
%   c = cameraCreate('ideal')
%   c = cameraCreate('L3');
%   c = cameraCreate('monochrome');
%
%
% See also: v_camera
%
% Copyright Imageval, LLC 2012

if ieNotDefined('cType'), cType = 'default'; end

cType = ieParamFormat(cType);

switch cType
    case 'default'
        camera.name = 'default';
        camera.type = 'camera';
        
        disp('Camera from default oi,sensor and ip')
        
        oi = oiCreate;
        sensor = sensorCreate;
        ip     = ipCreate;
        camera = cameraSet(camera,'oi',oi);
        camera = cameraSet(camera,'sensor',sensor);
        camera = cameraSet(camera,'ip',ip);
        
    case {'current'}

        camera.name = 'current';
        camera.type = 'camera';
        
        oi = ieGetObject('oi');
        if isempty(oi)
            fprintf('Creating new oi (default)\n');
            oi = oiCreate;
        else
            fprintf('Using current oi %s\n',oiGet(oi,'name'));
        end
        camera = cameraSet(camera,'oi',oi);
        
        sensor = ieGetObject('sensor');
        if isempty(sensor)
            fprintf('Creating new sensor (default)\n');
            sensor = sensorCreate;
        else
            fprintf('Using current sensor %s\n',sensorGet(sensor,'name'));
        end
        camera = cameraSet(camera,'sensor',sensor);
        
        ip = ieGetObject('ip');
        if isempty(ip)
            fprintf('Creating new ip (default)\n');
            ip = ipCreate;
        else
            fprintf('Using current ip %s\n',ipGet(ip,'name'));
        end
        camera = cameraSet(camera,'ip',ip);
        
    case 'ideal'
        % Noise free, ideal camera used in comparison
        camera.name   = 'ideal';
        camera.type   = 'camera';
        camera.oi     = oiCreate;
        camera.sensor = sensorCreateIdeal;
        camera.vci    = ipCreate;
            
    case 'idealmonochrome'
        % Noise-free monochrome.  Photon noise included, though.
        camera.name   = 'ideal monochrome';
        camera.type   = 'camera';
        camera.oi     = oiCreate;
        camera.sensor = sensorCreateIdeal('monochrome');
        camera.vci    = ipCreate;
        
    case 'monochrome'
        % Default monochrome
        camera.name   = 'monochrome';
        camera.type   = 'camera';
        camera.oi     = oiCreate;
        camera.sensor = sensorCreate('monochrome');
        camera.vci    = ipCreate;
        
    case 'l3'
        % Use L3 structures to create the camera
        if ~isempty(varargin)
            % An L3 structure was passed in.
            L3 = varargin{1};

            % Copy the oi/sensor structures into the camera structure.
            % But don't copy the data
            % Ultimately, the code should always compute on the camera
            % structures and just keep the L3 oi/sensor as parameters.  But
            % that isn't how things work just now in L3Train.
            % The reason is that we wrote L3 before we wrote camera, sigh.
            camera.name   = 'L3';
            camera.type   = 'camera';
            camera.oi = oiClearData(L3Get(L3,'oi'));
            camera.sensor = L3Get(L3,'design sensor');
            camera.vci = ipCreate('L3',[],[],L3ClearData(L3));
            
        else
            % Don't have an L3 structure or anything else.  Just load the
            % default L3 camera that is stored ? in ISET? in L3/data?
            dName = 'L3defaultcamera';
            fprintf('Loading %s - the trained (RGBW) camera\n',dName);
            tmp = load('L3defaultcamera'); camera = tmp.camera;
            clear tmp;
            
        end
        
    otherwise
        error('Unrecognized camera type %s\n',cType);
        
end

end
