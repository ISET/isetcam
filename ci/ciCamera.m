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
        cmodule = []; % 1 (or more) CModules
        % probably need to superset this
        isp = [];     % an ip or maybe something that extends an ip
        numHDRFrames = 3;
        numBurstFrames = 3;
        expTimes = [];
    end
    
    methods
        function obj = ciCamera() % parameters TBD
            obj.cmodule = ciCModule(); % 1 (or more) CModules
            obj.isp = ciIP();     % an ip or maybe something that extends an ip
            %CICAMERA Construct an instance of the generic camera
            %"super-class"
        end
        
        % Expected to be over-ridden in sub-classes
        % but they can still call us for "generic" processing.
        % There may also be lower-level touchpoints for sub-classing
        % so that they don't need to re-implement all of this. . .
        function ourPicture = TakePicture(obj, aCIScene, intent, options)
            %TakePicture Main function telling us to create a photo
            arguments
                obj;
                aCIScene;
                intent;
                options.numHDRFrames = 3;
                options.imageName char = '';
                options.reRender (1,1) {islogical} = true;
                options.expTimes = [];
            end
            obj.numHDRFrames = options.numHDRFrames;
            obj.expTimes = options.expTimes;
            if ~isempty(options.imageName) 
                obj.isp.ip = ipSet(obj.isp.ip, 'name', options.imageName);
            end
            
            % aCIScene is a ciScene
            % That gives us .preview, .render
            % with support for motion and an array of shutter times
            %
            % In addition to main intents, someday we could get fancy
            % and allow the user to specify one of a multiple of cameras
            % (like Wide-angle, or Telephoto)
            
            % Determine how to capture & process based on desired outcome
            % For complex intents, process may involve taking a preview
            % of the scene (maybe just the first frame of a multiple scene
            % input, so maybe we don't need to do a CScene.Preview?
            
            if ~exist('aCIScene', 'var') || isempty(aCIScene)
                aCIScene = ciScene('pbrt');
            end
            if ~exist('intent','var') || isempty(intent)
                intent = 'Auto';
            end
            
            % Based on the intent and optionally the results of
            % a preview image, determine number of frames and exposure
            % time(s). Potentially more sophisticated stuff as well
            
            % Comes back as a cell array in case we want to do more
            % sophisticated multi-frame previews eventually.
            previewImages = aCIScene.preview();
            
            % Given our preview & intent the camera can decide
            % how many images to take and at what exposure
            % for now we assume a single camera module
            % IF a camera is okay with standard processing,
            % could just over-ride planCaptures and leave the rest alone.
            if isequal(obj.expTimes, [])
                [expTimes] = obj.planCaptures(previewImages, intent);
            else
                expTimes = obj.expTimes;
            end
            % As a simple test just get a scene we can use!
            [sceneObjects, sceneFiles] = aCIScene.render(expTimes, 'reRender', options.reRender);
            
            % Simplest case, now that we have the nFrames & expTimes
            % We want to call our camera module(s).
            % Each returns an array of sensor objects with the images
            % pre-computed
            sensorImages = obj.cmodule.compute(sceneObjects, expTimes);
            
            % generic version, currently just prints out each processed
            % image from the sensor
            ourPicture = obj.computePhoto(sensorImages, intent);

            
            %{
            or we could do it this way and invoke each sensor separately?
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
        
        function ourPhoto = computePhoto(obj, sensorImages, intent)
            for ii=1:numel(sensorImages)
                sensorWindow(sensorImages(ii));
                ourPhoto = obj.isp.compute(sensorImages(ii));
                ipWindow(ourPhoto);
            end
        end
        
        function [expTimes] = planCaptures(obj, previewImages, intent)
            switch intent
                case {'Auto', 'Portrait', 'Scenic', 'Action', ...
                        'Night'}
                    % split these apart as they are implemented
                    % we might also want to add more "techie" intents
                    % like 'burst' rather than relying on them being
                    % activated based on some other user choice
                    
                    % For now assume we're a very simple camera!                    
                    % And we can do AutoExposure to get our time.
                    % We also only use a single preview image
                    oi = oiCompute(previewImages{1}, obj.cmodule.oi);
                    % Compute exposure times if they weren't passed to us
                    if isequal(obj.expTimes, [])
                        expTimes = [autoExposure(oi, obj.cmodule.sensor)];
                    else
                        expTimes = obj.expTimes;
                    end
                    % When we ask for a preview, it messes up FOV of other
                    % sensors?
                    % test to see if preview works
                    %previewScene = scene.preview();
                    %sceneLuminance = sceneGet(previewScene{1}, 'mean luminance');
                    %fprintf("Scene Luminance is: %f\n", sceneLuminance);
                    %for Debugging
                    %sceneWindow(previewScene{1});
                    
                    
                case 'HDR'
                    % use the bracketing code
                    expTimes = [.05 .01 .20];
                case 'Burst'
                    % not sure burst is ever really a "user intent" but
                    % it might make sense to allow it. Otherwise it could
                    % just be the way a particular camera implements
                    % some of the other intents
                    expTimes = [.05 .05 .05];
                case 'Pro'
                    % here we allow the user to set exposure time,
                    % focus, exposure comp if AutoExpose, WB, etc.
                    % Might force camera to a specific module also?
                    % Zoom is settable, but might be digital??
                    % Aperture also, maybe some shutter modes at some point
                    expTimes = [.1];
                case 'otherwise'
                    error("Unknown photo intent");
            end
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

