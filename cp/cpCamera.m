classdef cpCamera < handle
    %cpCamera Computational Camera
    %   Base class, allows extension for CP features, including:
    %   In cpBurstCamera:
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
        cmodules = cpCModule.empty; % 1 (or more) CModules
        isp = [];     % an extended ip
        expTimes = [];
        supportedIntents;
    end
    
    methods
        function obj = cpCamera() % parameters TBD
            %cpCamera Construct an instance of the generic cpCamera
            %"super-class"
            obj.cmodules(1) = cpCModule(); % 1 (or more) CModules
            obj.isp = cpIP();     % extended ip
            obj.supportedIntents = {'Auto', 'Pro'};
        end
        
        % Expected to be over-ridden in sub-classes for specific
        % processing, but they can still call us for "generic" processing.
        % There may also be lower-level touchpoints for sub-classing
        % so that they don't need to re-implement all of this. . .
        function ourPicture = TakePicture(obj, aCPScene, intent, options)
            %TakePicture Main function telling us to create a photo
            arguments
                obj;
                aCPScene;
                intent;
                options.imageName char = '';
                options.reRender (1,1) {islogical} = true;
                options.expTimes = [];
                options.insensorIP = obj.isp.insensorIP; % default
                options.focusMode char = 'Auto';
                options.focusParam = 'Center'; % for Manual is distance in m
            end
            obj.expTimes = options.expTimes;
            % Not sure yet whether we need these at the class level
            %obj.focusMode = options.focusMode;
            %obj.focusParam = options.focusParam;
            
            if ~isempty(options.imageName)
                obj.isp.ip = ipSet(obj.isp.ip, 'name', options.imageName);
            end
            
            % aCIScene is a cpScene
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
            
            if ~exist('aCPScene', 'var') || isempty(aCPScene)
                aCPScene = cpScene('pbrt');
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
            previewImages(1) = aCPScene.preview();
            
            % Given our preview & intent the camera can decide
            % how many images to take and at what exposure
            % for now we assume a single camera module
            % IF a camera is okay with standard processing,
            % could just over-ride planCaptures and leave the rest alone.
            if isequal(obj.expTimes, [])
                [obj.expTimes] = obj.planCaptures(previewImages(1), intent);
            end
            
            % Simplest case, now that we have the nFrames & expTimes
            % We want to call our camera module(s).
            % Each returns an array of sensor objects with the images
            % pre-computed
            [sensorImages, focusDistances] = obj.cmodules(1).compute(aCPScene, obj.expTimes, 'focusMode', options.focusMode,...
                'focusParam', options.focusParam,'intent',intent);
            
            % generic version, currently just prints out each processed
            % image from the sensor
            ourPicture = obj.computePhoto(sensorImages, intent, ...
                'insensorIP', options.insensorIP, 'scene', aCPScene, ...
                'focusDistances', focusDistances);
            
        end
        
        % Here sub-classes over-ride default processing to compute a photo after we've
        % captured one or more frames. This allows burst & hdr, for example.
        function ourPhoto = computePhoto(obj, sensorImages, intent, options)
            arguments
                obj
                sensorImages;
                intent;
                options.insensorIP = true;
                options.scene = [];
                options.focusDistances = [];
            end
            ourPhoto = obj.isp.ispCompute(sensorImages, intent, 'insensorIP', ...
                options.insensorIP, 'scene', options.scene, ...
                'focusDistances',options.focusDistances);
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
                        expTimes = obj.aExposure(oi);
                    else
                        expTimes = obj.expTimes;
                    end
                    
                case 'Pro'
                    % TODO: here we allow the user to set exposure time,
                    % focus, exposure comp if AutoExpose, WB, etc.
                    % Might force camera to a specific module also?
                    % Zoom is settable, but might be digital??
                    % Aperture also, maybe some shutter modes at some point
                    expTimes = [1]; % match default integration time?
                case 'otherwise'
                    error("Unknown photo intent. You may need a specialized sub-class implementation.");
            end
        end
        
        function eTimes = aExposure(obj, oi)

            %{
            % optional code for center-weighted
            % pick a rect in the center of the oi
            iW = oiGet(oi,'cols');
            iH = oiGet(oi,'rows');
            fraction = 10; % arbitrary area around the center
            top = floor((iH / 2) - (iH / (fraction*2)));
            left = floor((iW / 2) - (iW / (fraction*2)));
            w = floor(iW / fraction);
            h = floor(iH / fraction);
            cRect = [top, left, w, h];
            %}
            eTimes = autoExposure(oi, obj.cmodules(1).sensor, .95, 'default');
        end

        function infoArray = showInfo(obj)
            infoArray = {'Camera Type:', class(obj)};
            infoArray = [infoArray; {'Intents', strjoin(obj.supportedIntents)}];
        end
    end
end

