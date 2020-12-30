classdef ciScene
    %CISCENE Computational enhancement of scene struct
    %   Allows for computed scenes, that can include
    %   camera motion and motion of objects in the scene
    %
    %   For full functionality, accepts a PBRT scene from
    %   which it can generate a series of usable scenes or ois,
    %   either as a scene name, or as a Recipe
    %
    %   Can also accept ISET scenes (.mat) and images, but
    %   with reduced functionality
    %
    %   Can also retrieve a scene preview, as CCamera/CModule may rely on
    %   that to make decisions about setting capture parameters
    %
    % History:
    %   Initial Version: D. Cardinal 12/2020
    %
    % Sample Code:
    %   load the Cornell Box + Stanford bunny
    %   set up for moving the bunny
    %   then generate a series of scenes based on that
    %{
    	ourScene = ciScene();
        ourScene.initialScene = <name of cb_bunny pbrt resource>
        ourScene.cameraMotion = [0 0 0];
        % bunny is currently labeled Default
        ourScene.objectMotion = [['Default' [1 0 0] [0 0 0]]];
        ourScene.exposureTimes = [.5 .5 .5 .5];
        ourScene.cacheName = 'cb_bunny_slide';
    
        previewScene = ourScene.preview();
        renderedScenes = ourScene.render();
    %}
    
    properties
        sceneType = '';
        initialScene = ''; % Ideally this is a PBRT scene, but we also need
        % to handle the case where it is an ISET scene
        % or even just an image file
        scenePath = 'Cornell_BoxBunnyChart'; %Default PBRT scene
        sceneName =  'cornell box bunny chart'; 
        sceneFileName = '';
        thisR;
        
        resolution = [512 512]; 
        
        cameraMotion = []; % extent of camera motion in meters per second
        % ['<cameraname>' [tx ty tz] [rx ry rz]]
        
        objectMotion = []; 
        
        expTimes = [1.5];    % single or array of exposure times to use when
        % generating the rendered images
        
        cacheName = '';   % Because scenes can be expensive to render, we
        % store them in /local. But to use them as a cache
        % we need to make sure they are relevant. We could
        % do what we do with OI and match the entire setting
        % structure, or here we just let the user "tag" a
        % cache entry to see if they want to re-use it.
        % individual scene frames are stored as files under
        % this folder.
        
        lensModel = '';   % Since PBRT can accept lens models and return an OI
        % provide the option to specify one here. In this
        % case, instead of returning an array of scenes, we
        % return an array of oi's, that can be fed directly
        % to a sensor. Default is simple "pinhole"
        
        numFrames = 1;
        
    end
    
    %% Do the work here
    methods
        function obj = ciScene(sceneType, varargin)
            %CISCENE Construct an instance of this class
            %   allow whatever init we want to accept in the creation call
            obj.sceneType = sceneType;
            switch obj.sceneType
                case 'recipe'
                    if exist(varargin{1},'var')
                        obj.thisR = varargin{1};
                    end
                case 'pbrt'
                    if exist(varargin{1}, 'var')
                        obj.scenePath = varargin{1};
                    end
                    if exist(varargin{2}, 'var')
                        obj.sceneName = varargin{2};
                    end
                case 'iset scene file'
                    if isfile(varargin{1})
                        obj.sceneFileName = varargin{1};
                    end 
                case 'iset scene'
                    if exist(varargin{1},'var')
                        obj.initialScene = varargin{1};
                    end
                case 'image'
                    if exist(varargin{1}, 'var')
                        obj.sceneFileName = varargin{1};
                    end
                otherwise
                    error("Unknown Scene Type");
            end
            
        end
        
        %% Main rendering function
        % We know the scene, but need to pass Exposure Time(s),
        % which also gives us numFrames
        function [sceneObjects, sceneFiles] = render(obj,expTimes)
            % render uses what we know about the initial
            % image and subsequent motion requests
            % to generate one or more output scene or oi structs
            
            %   If lensmodel is set, it is used with PBRT and
            %   we return an array of oi objects, otherwise scenes
            
            obj.numFrames = numel(expTimes);
            
            % initialize our pbrt scene
            if ~piDockerExists, piDockerConfig; end
            % read scene (defaults is cornell box with bunny)
            if ~exist(obj.thisR, 'var') || isempty(obj.thisR)
                obj.thisR = piRecipeDefault('scene name', obj.sceneName);
            end
            % Modify the film resolution
            % FIX: This should be set to the sensor size, ideally
            % or maybe to a fraction for faster performance
            obj.thisR.set('filmresolution', obj.resolution);
            
            %% Add new light
            % UPDATE THIS WITH NEW CODE FROM MOTION TUTORIAL IN ISET3D
            % ONCE IT IS IN GOOD SHAPE.
            obj.thisR = piLightAdd(obj.thisR,...
                'type','point',...
                'light spectrum','Tungsten',...
                'cameracoordinate', true);
            
            imageFolderPath = fullfile(isetRootPath, 'local', obj.scenePath, 'images');
            if ~isfolder(imageFolderPath)
                mkdir(imageFolderPath);
            end
            sceneFiles = [];
            sceneObjects = [];
            
            % process object motion
            for ii = 1:numel(obj.objectMotion)
                ourMotion = obj.objectMotion{ii};
                    if ~isempty(ourMotion{1})
                        obj.thisR.set('asset', ourMotion{1}, 'motion', 'translation', ourMotion{2});
                        obj.thisR.set('asset', ourMotion{1}, 'motion', 'rotation', ourMotion{3});
                    end
                    %thisR.set('asset', bunnyName, 'translation', [moveX, moveY, moveZ]);
                
            end
            for ii = 1:obj.numFrames
                imageFilePrefixName = fullfile(imageFolderPath, append("frame_", num2str(ii)));
                imageFileName = append(imageFilePrefixName,  ".mat");
                
                %IF we haven't rendered before, do it now
                if ~isfile(imageFileName)
                    
                    % if we want movement during each frame, need to get
                    % the actual exposure time from the caller:
                    % if expTime is single value, can we sub-index 1?
                    
                    obj.thisR.set('cameraexposure', obj.expTimes(ii));
                    
                    % Hack to test shutter
                    % unfortunately, it doesn't seem to do what we want
                    %obj.thisR.set('shutteropen', 1);
                    %obj.thisR.set('shutterclose', 25);
                    
                    %% Write recipe
                    piWrite(obj.thisR);
                    
                    %% Render and visualize
                    % Should we also allow for keeping depth if needed for
                    % post-processing?
                    [sceneObject, results] = piRender(obj.thisR, 'render type', 'radiance');
                    sceneToFile(imageFileName,sceneObject);
                    
                    % this is mostly just for debugging & human inspection
                    sceneSaveImage(sceneObject,imageFilePrefixName);
                else
                    sceneObject = sceneFromFile(imageFileName, 'multispectral');
                end
                sceneObjects = [sceneObjects sceneObject]; %#ok<AGROW>
                sceneFiles = [sceneFiles imageFileName]; %#ok<AGROW>
            end
            
            
        end
        
        function outputArg = preview(obj, XXX)
            % get a preview that the camera can use to plan capture
            % settings
        end
        
        function load(obj, cSceneFile)
            % load cScene data back in
            load(cSceneFile, obj);
        end
        
        function save(obj, cSceneFile)
            % write out cScene data for later re-use
            save(cSceneFile, obj);
        end
        
    end
end

