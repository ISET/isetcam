function val = cameraGet(camera,param,varargin)
%Get function for camera structure
%
%   val = cameraGet(camera,param,varargin)
%
% The camera structure contains the oi, sensor, and image processing
% modules needed to simulate a full camera.  This is a gateway routine for
% retrieving parameters from any of those structures.
%
% To specify a parameter, you can generally use the syntax
%
%   cameraGet(camera,'sensor/size'), or cameraGet(camera,'prnu')
%
% If you include the sensor/ in this example, the parameter will definitely
% be retrieved from the sensor object.  In the case of some parameters,
% such as prnu, there is no ambiguity.  So the proper object will be
% recognized.  But in the case of other parameters, such as 'size', there
% is ambiguity and you should (must) specify the object.
%
% Camera Parameters
%
%   name:
%   type:
%   oi:
%   optics:
%   sensor:
%   pixel:
%   ip:
%   image: Rendered image in lRGB format
%   l3:
%
% Examples:
%  (we are good for up to 1 varargin in oi for now.  Working to do better).
%
%  camera = cameraCreate;
%
%  cameraGet(camera,'oi')
%  cameraGet(camera,'oi area','mm')
%
%  cameraGet(camera,'optics')
%  cameraGet(camera,'pixel')
%  cameraGet(camera,'optics fnumber')
%  cameraGet(camera,'optics numerical aperture')
%  cameraGet(camera,'optics focal length')
%
%  cameraGet(camera,'sensor')
%  cameraGet(camera,'ip')
%
%  cameraGet(camera,'vci result')
%  cameraGet(camera,'vci transforms')
%  cameraGet(camera,'ip transforms')
%
% (c) Stanford VISTA Toolbox

if ~exist('camera', 'var') || isempty(camera), error('camera struct required'); end
if ~exist('param','var')   || isempty(param),  error('param must be defined.'); end

% Parse param to see if it indicates which object.  Store parameter.
[oType,p] = ieParameterOtype(param);

switch oType
    
    % If the object type has been identified, use the specific object get
    % call.
    % Not sure how to deal with multiple elements in varargin
    case {'oi'}
        if isempty(p), val = camera.oi;
        elseif   isempty(varargin), val = oiGet(camera.oi,p);
        else val = oiGet(camera.oi,p,varargin{1});
        end
        
    case {'optics'}
        if isempty(p), val = camera.oi.optics;
        elseif   isempty(varargin), val = opticsGet(camera.oi.optics,p);
        else val = opticsGet(camera.oi.optics,p,varargin{1});
        end
        
    case {'sensor'}
        % Not dealing with varargin yet
        if isempty(p), val = camera.sensor;
        elseif isempty(varargin), val = sensorGet(camera.sensor,p);
        else val = sensorGet(camera.sensor,p,varargin{1});
        end
        
    case {'pixel'}
        if     isempty(p), val = camera.sensor.pixel;
        elseif isempty(varargin), val = pixelGet(camera.sensor.pixel,p);
        else   val = pixelGet(camera.sensor.pixel,p,varargin{1});
        end
        
    case {'ip'}
        if isempty(p), val = camera.vci;
        elseif isempty(varargin), val = ipGet(camera.vci,p);
        else val = ipGet(camera.vci,p,varargin{1});
        end
        
    case {'l3'}
        if isempty(p), val = camera.vci.L3;
        elseif isempty(varargin), val = L3Get(camera.vci.L3,p);
        else val = L3Get(camera.vci.L3,p,varargin{1});
        end
        
    otherwise
        % Param must refer to one of the slots in the camera structure
        switch(ieParamFormat(param))
            
            % Book-keeping
            case {'name'}
                val = camera.name;
            case {'type'}
                val = camera.type;
                
            case {'vcitype'}
                % Let's us know if this is default, L3, or some other processor in
                % the future
                pType = cameraGet(camera,'vci','name');
                pType = ieParamFormat(pType);
                
                if strcmp(pType,'l3') || strcmp(pType,'l3global'), val = 'l3';
                else val = 'default';
                end
                
            case {'image'}
                % Returns the camera image, which is stored in the vci struct.
                % Format is lrgb and scaling is probably arbitrary.
                val = ipGet(cameraGet(camera,'vci'),'display data');
                
            case {'l3'}
                % L3 structure
                if isfield(camera,'vci','L3'), val = camera.vci.L3; end
                
                %% Metrics - tentative
                % Idea is that a camera could also contain some metrics that can be
                % stored in camera.metrics.  Using cameraGet(camera,'metric',XXX) where
                % XXX is the name of a metric will either:
                %   1.  Return the existing structure stored for that metric
                %   2.  If the structure does not exist, calculate it.
                %
                % The metric should then be set so it does not need to be recalculated
                % again using:  camera = cameraSet(camera, 'metric', val, metricname);
                %
                % Hopefully this structure will help keeping storing and accessing any
                % interesting predefined metrics for the camera.
                
                
            case {'metric','metrics'}
                % Examples:
                %    metric = cameraGet(camera, 'metric', 'mcc color');
                %    metric = cameraGet(camera, 'metric', 'slanted edge');
                %    metric = cameraGet(camera, 'metric', 'acutance');
                
                if isempty(varargin)        % if there is no 2nd argument
                    val = camera.metrics;   % return the entire metrics structure
                    return;
                else
                    if ~isfield(camera, 'metrics'); camera.metrics = []; end
                    metrics = camera.metrics;
                    if length(varargin) == 1
                        metricname = ieParamFormat(varargin{1});
                        if isfield(metrics, metricname);
                            val = getfield(metrics, metricname);
                        else
                            metric = metricsCamera(camera, metricname);
                            val = metric;   %return newly calculated metric
                        end
                    else
                        error('Only one additional input allowed for metrics.')
                    end
                end
                
            otherwise
                error('Unknown camera parameter: %s\n',param);
        end
end

end
