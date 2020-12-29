classdef CScene
    %CSCENE Computational enhancement of scene struct
    %   Allows for computed scenes, that can include
    %   camera motion and motion of objects in the scene
    %
    %   For full functionality, accepts a PBRT scene from
    %   which it can generate a series of usable scenes or ois
    %
    %   Can also accept ISET scenes (.mat) and images, but
    %   with reduced functionality
    %
    %   Can also retrieve a scene preview, as CCamera/CModule may rely on
    %   that to make decisions about setting capture parameters
    %
    % History:
    %   Initial Version: D. Cardinal 12/20
    %
    % Sample Code:
    %   load the Cornell Box + Stanford bunny
    %   set up for moving the bunny
    %   then generate a series of scenes based on that
    %{
    	ourScene = Cscene();
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
        initialScene = ''; % Ideally this is a PBRT scene, but we also need
        % to handle the case where it is an ISET scene
        % or even just an image file
        scenePath = 'Cornell_BoxBunnyChart'; %Default PBRT scene
        sceneName =  'cornell box bunny chart'; 
        
        cameraMotion = []; % extent of camera motion in meters per second
        % ['<cameraname>' [tx ty tz] [rx ry rz]]
        
        objectMotion = []; % okay, this could be complicated.
        % we have object names, translation, and rotation
        % Seems like a good argument for being able to write
        % out CScenes, that could encapsulate a "Setting"
        % and then be re-used as test cases
        % [['<objectname'] [tx ty tz] [rx ry rz]], repeat]
        
        expTimes = [.5];    % single or array of exposure times to use when
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
        function obj = CScene(scenePath, sceneName)
            %CSCENE Construct an instance of this class
            %   allow whatever init we want to accept in the creation call
            obj.scenePath = scenePath;
            obj.sceneName = sceneName;
        end
        
        %% Main rendering function
        % We know the scene, but need to pass Exposure Time(s),
        % which also gives us numFrames
        function sceneFiles = render(obj,expTimes)
            % render uses what we know about the initial
            % image and subsequent motion requests
            % to generate one or more output scene or oi structs
            
            %   If lensmodel is set, it is used with PBRT and
            %   we return an array of oi objects, otherwise scenes
            
            obj.numFrames = numel(expTimes);
            
            % initialize our pbrt scene
            if ~piDockerExists, piDockerConfig; end
            % read scene (defaults is cornell box with bunny)
            thisR = piRecipeDefault('scene name', obj.sceneName);
            
            % Modify the film resolution
            % FIX: This should be set to the sensor size, ideally
            % or maybe to a fraction for faster performance
            thisR.set('filmresolution', [512, 512]);
            
            %% Add new light
            % UPDATE THIS WITH NEW CODE FROM MOTION TUTORIAL IN ISET3D
            % ONCE IT IS IN GOOD SHAPE.
            thisR = piLightAdd(thisR,...
                'type','point',...
                'light spectrum','Tungsten',...
                'cameracoordinate', true);
            
            % Find the bunny! (our default)
            bunnyName = 'Default'; % hopefully will get changed
            
            imageFolderPath = fullfile(isetRootPath, 'local', obj.scenePath, 'images');
            if ~isfolder(imageFolderPath)
                mkdir(imageFolderPath);
            end
            sceneFiles = [];
            for ii = 1:obj.numFrames
                imageFilePrefixName = fullfile(imageFolderPath, append("frame_", num2str(ii)));
                imageFileName = append(imageFilePrefixName,  ".mat");
                
                % TOTAL HACK:
                motionX = .1;
                motionY = .1;
                motionZ = 0;
                
                %IF we haven't rendered before, do it now
                %FIX: CURREENT SIMPLE HARD-CODE MOTION
                % NEEDS TO READ objectmotion & cameramotion arrays and
                % process
                if ~isfile(imageFileName)
                    moveX = motionX * (ii - 1);
                    moveY = motionY * (ii - 1);
                    moveZ = motionZ * (ii - 1);
                    
                    % if we want movement during each frame, need to get
                    % the actual exposure time from the caller:
                    % if expTime is single value, can we sub-index 1?
                    thisR.set('cameraexposure', obj.expTimes(ii));
                    
                    % setting motion isn't working for me:
                    %thisR.set('asset', bunnyName, 'motion', 'translation', [moveX, moveY, moveZ]);
                    % but translation does:
                    thisR.set('asset', bunnyName, 'translation', [moveX, moveY, moveZ]);
                    
                    %% Write recipe
                    piWrite(thisR);
                    
                    %% Render and visualize
                    % Should we also allow for keeping depth if needed for
                    % post-processing?
                    [scene, results] = piRender(thisR, 'render type', 'radiance');
                    sceneToFile(imageFileName,scene);
                    sceneSaveImage(scene,imageFilePrefixName);
                end
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

