classdef ciCamera < handle
    %CICAMERA Computational Camera
    %   Base class, allows extension for CI features, including:
    %   In ciBurstCamera:
    %   * Bracketing (HDR)
    %   * Burst captures
    %   * Support for camera and object motion
    %   * Works with pbrt recipes, iset scenes, and images
    %   FUTURE:
    %   * More sophisticated ISP features
    %   *     including support for "Intents" provided by the user
    %   *     and potentially for multiple camera modules used for one
    %         photo
    
    % History:
    %   Initial Version: D.Cardinal 12/2020
    
    properties
        cmodules = ciCModule.empty; % 1 (or more) CModules
        isp = [];     % an extended ip
        expTimes = [];
        supportedIntents = {'Auto', 'Pro'};
    end
    
    methods
        function obj = ciCamera() % parameters TBD
            %CICAMERA Construct an instance of the generic ciCamera
            %"super-class"
            obj.cmodules(1) = ciCModule(); % 1 (or more) CModules
            obj.isp = ciIP();     % extended ip
            
        end
        
        % Expected to be over-ridden in sub-classes for specific
        % processing, but they can still call us for "generic" processing.
        % There may also be lower-level touchpoints for sub-classing
        % so that they don't need to re-implement all of this. . .
        function ourPicture = TakePicture(obj, aCIScene, intent, options)
            %TakePicture Main function telling us to create a photo
            arguments
                obj;
                aCIScene;
                intent;
                options.imageName char = '';
                options.reRender (1,1) {islogical} = true;
                options.expTimes = [];
                options.stackFrames = 0;
            end
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
            
            % Preview(s) come back as a cell array in case we want to do more
            % sophisticated multi-frame previews eventually. For now we
            % just use one preview image:
            previewImages(1) = aCIScene.preview();
            
            % Given our preview & intent the camera can decide
            % how many images to take and at what exposure
            % for now we assume a single camera module
            % IF a camera is okay with standard processing,
            % could just over-ride planCaptures and leave the rest alone.
            if isequal(obj.expTimes, [])
                [expTimes] = obj.planCaptures(previewImages(1), intent);
            else
                expTimes = obj.expTimes;
            end
            
            % Render scenes as needed. Note that if pbrt has a lens file
            % then 'sceneObjects' are actually oi structs
            [sceneObjects, sceneFiles] = aCIScene.render(expTimes, 'reRender', options.reRender);
            
            % Simplest case, now that we have the nFrames & expTimes
            % We want to call our camera module(s).
            % Each returns an array of sensor objects with the images
            % pre-computed
            sensorImages = obj.cmodules(1).compute(sceneObjects, expTimes, 'stackFrames', options.stackFrames);
            
            % generic version, currently just prints out each processed
            % image from the sensor
            ourPicture = obj.computePhoto(sensorImages, intent);

            % alternate method of doing multi-sensor:
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
                
        % A key element of modern computational cameras is their ability
        % to use statistics from the scene (in this case via preview 
        % image(s) to plan how many frames to capture and with what settings. 
        function [expTimes] = planCaptures(obj, previewImages, intent)
            switch intent
                case {'Auto', 'Portrait', 'Scenic', 'Action', ...
                        'Night'}
                    % split these apart as they are implemented
                    % we might also want to add more "techie" intents
                    
                    % For now assume we're a very simple camera!                    
                    % And we can do AutoExposure to get our time.
                    % We also only use a single preview image
                    if isequal(previewImages{1}.type, 'opticalimage')
                        oi = previewImages{1};
                    else
                        oi = oiCompute(previewImages{1}, obj.cmodules(1).oi);
                    end
                    % Compute exposure times if they weren't passed to us
                    if isequal(obj.expTimes, [])
                        expTimes = [autoExposure(oi, obj.cmodules(1).sensor)];
                    else
                        expTimes = obj.expTimes;
                    end
                    
                case 'Pro'
                    % TODO: here we allow the user to set exposure time,
                    % focus, exposure comp if AutoExpose, WB, etc.
                    % Might force camera to a specific module also?
                    % Zoom is settable, but might be digital??
                    % Aperture also, maybe some shutter modes at some point
                    expTimes = [.1];
                case 'otherwise'
                    error("Unknown photo intent. You may need a specialized sub-class implementation.");
            end
        end
        
        function infoArray = showInfo(obj)
            infoArray = {'Intents', strjoin(obj.supportedIntents)};
        end
    end
end

