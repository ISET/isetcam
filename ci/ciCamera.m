classdef ciCamera
    %CICAMERA Computational Camera
    %   Allows for more complex camera designs, potentially including:
    %   * Burst captures, including support for camera and object motion
    %   * More sophisticated ISP features
    %   *     including support for "Intents" provided by the user
    %   *     and potentially for multiple camera modules used for one
    %         photo
    
    % History:
    %   Initial Version: D.Cardinal 12/2020
    
    properties
        cmodule = ciCModule(); % 1 (or more) CModules
        % probably need to superset this
        isp = ipCreate();     % an ip or maybe something that extends an ip
        
    end
    
    methods
        function obj = ciCamera() % parameters TBD
            %CICAMERA Construct an instance of this class
            
        end
        
        % Expected to be over-ridden in sub-classes
        % but they can still call us for "generic" processing.
        % There may also be lower-level touchpoints for sub-classing
        % so that they don't need to re-implement all of this. . .
        function ourPicture = TakePicture(obj, scene, intent)
            %TakePicture Main function telling us to create a photo
            
            % scene can be either a scene struct (static)
            % or an array of scenes or a CSCene (in theory)
            % unless we want to force the caller to generat a CScerne
            % to simplify our life. That gives us .preview, .render
            % with support for motion and an array of shutter times
            % 
            % In addition to main intents, someday we could get fancy
            % and allow the user to specify one of a multiple of cameras
            % (like Wide-angle, or Telephoto)
            
            % Determine how to capture & process based on desired outcome
            % For complex intents, process may involve taking a preview
            % of the scene (maybe just the first frame of a multiple scene
            % input, so maybe we don't need to do a CScene.Preview?
            
            if ~exist('scene', 'var') || isempty(scene)
                scene = ciScene();
            end
            if ~exist('intent','var') || isempty(intent)
                intent = 'Auto';
            end
            
            % Based on the intent determine number of frames and exposure
            % time(s). Potentially more sophisticated stuff as well
            
            switch intent
                case {'Auto', 'Portrait', 'Scenic', 'Action', ...
                        'Night'}
                    % split these apart as they are implemented
                    % we might also want to add more "techie" intents
                    % like 'burst' rather than relying on them being
                    % activated based on some other user choice
                                        
                    % For now assume we're a very simple camera!
                    nFrames = 1;
                    
                    % And we can do AutoExposure to get our time.
                    expTimes = [.5]; % FIX TO GET REAL EXPOSURE!
                    
                    % As a simple test just get a scene we can use!
                    [sceneObjects, sceneFiles] = scene.render(expTimes);
                    
                case 'HDR'
                    % use the bracketing code
                case 'burst'
                    % not sure burst is ever really a "user intent" but
                    % it might make sense to allow it. Otherwise it could
                    % just be the way a particular camera implements
                    % some of the other intents
                case 'pro'
                    % here we allow the user to set exposure time,
                    % focus, exposure comp if AutoExpose, WB, etc.
                    % Might force camera to a specific module also?
                    % Zoom is settable, but might be digital??
                    % Aperture also, maybe some shutter modes at some point
                case 'otherwise'
                    error("Unknown photo intent");
            end
            
            % Simplest case, now that we have the nFrames & expTimes
            % We want to call our camera module(s).
            % Each returns an array of sensor objects with the images
            % pre-computed
            sensorImages = obj.cmodule.compute(sceneObjects);
            ourPicture = ipCompute(obj.isp, sensorImages);
%{
            for ii = 1:numel(useScenes)
                useableScene = sceneFromFile(useScenes(ii), 'multispectral');
                ourOIs = oiCompute(useableScene, obj.cmodule.oi);
                sceneFOV = [sceneGet(useableScene,'fovhorizontal'), sceneGet(useableScene,'fovvertical')];
                obj.cmodule.sensor = sensorSetSizeToFOV(obj.cmodule.sensor,sceneFOV,obj.cmodule.oi);
                ourCaptures = sensorCompute(obj.cmodule.sensor, ourOIs);
                ourPicture = ipCompute(obj.isp, ourCaptures);
            end
%}
          
            
        end
        
        function save(obj, sFileName)
            save(sFileName, obj);
        end
        
        function load(obj, lFileName)
            % how do we make sure this gets loaded into us
            % or should we just have an initializer that uses load?
            load(lFileName, obj)
        end
    end
end

