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
    % Parameters:
    %   Create:
    %       scenetype: 
    %           'recipe' -- previously-loaded recipe
    %           'pbrt'   -- a PBRT scene
    %           'iset'   -- an ISET scene file
    %           'scene'  -- previously-loaded ISET scene struct
    %           'image'  -- image file name
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
        sceneName =  'cornell box bunny chart'; %Default PBRT scene name
        sceneFileName = '';
        thisR;
        
        resolution = [512 512]; % default

        allowsCameraMotion = true;
        cameraMotion = []; % extent of camera motion in meters per second
        % ['<cameraname>' [tx ty tz] [rx ry rz]]
        
        allowsObjectMotion = false; % default until set
        objectMotion = []; % none until the user adds some 
        
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
        
        numFrames = 1; % just the default
        
    end
    
    %% Do the work here
    methods
        function obj = ciScene(sceneType, varargin)
            %CISCENE Construct an instance of this class
            %   allow whatever init we want to accept in the creation call
            obj.sceneType = sceneType;
            switch obj.sceneType
                case 'recipe' % we can pass a recipe directly if we already have one loaded
                    if exist(varargin{1},'var')
                        obj.thisR = varargin{1};
                        obj.allowsObjectMotion = true;
                    else
                        error("For recipe, need to pass in an object");
                    end
                case 'pbrt' % pass a pbrt scene 
                    if nargin > 1
                        obj.scenePath = varargin{1};
                    else
                        error("Need scene Path");
                    end
                    if nargin > 2
                        obj.sceneName = varargin{2};
                    else
                        error("Need scene Name");
                    end
                    
                    if ~piDockerExists, piDockerConfig; end
                    obj.thisR = piRecipeDefault('scene name', obj.sceneName);
                    obj.allowsObjectMotion = true;

                case 'iset scene file'
                    if isfile(varargin{1})
                        obj.sceneFileName = varargin{1};
                    end 
                    % TBD
                case 'iset scene'
                    if exist(varargin{1})
                        obj.initialScene = varargin{1};
                    end
                    % TBD
                case 'image'
                    if exist(varargin{1})
                        obj.sceneFileName = varargin{1};
                    end
                    % TBD
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
            obj.expTimes = expTimes;
            
            % The below code works for when we get a pbrt scene or a
            % recipe, but doesn't know what to do with an iset scene or one
            % or more pre-baked images.
            
            % initialize our pbrt scene
            if ~piDockerExists, piDockerConfig; end
            % read scene (defaults is cornell box with bunny)
            if ~exist('obj.thisR', 'var') || isempty(obj.thisR)
                obj.thisR = piRecipeDefault('scene name', obj.sceneName);
            end
            % Modify the film resolution
            % FIX: This should be set to the sensor size, ideally
            % or maybe to a fraction for faster performance
            obj.thisR.set('filmresolution', obj.resolution);
            
            %% Looks like we still need to add our own light
            obj.thisR = piLightAdd(obj.thisR,...
                'type','point',...
                'light spectrum','Tungsten',...
                'cameracoordinate', true);
            
            imageFolderPath = fullfile(isetRootPath, 'local', obj.scenePath, 'images');
            if ~isfolder(imageFolderPath)
                mkdir(imageFolderPath);
            end
            sceneFiles = [];
            if exist('sceneObjects', 'var') clear(sceneObjects); end
            
            % Okay we have object motion & numframes
            % but if Motion doesn't work, then we need to translate between
            % frames
            
            % process object motion if allowed
            if obj.allowsObjectMotion
                for ii = 1:numel(obj.objectMotion)
                    ourMotion = obj.objectMotion{ii};
                    if ~isempty(ourMotion{1})
                        obj.thisR.set('asset', ourMotion{1}, 'motion', 'translation', ourMotion{2});
                        obj.thisR.set('asset', ourMotion{1}, 'motion', 'rotation', ourMotion{3});
                    end
                    %thisR.set('asset', bunnyName, 'translation', [moveX, moveY, moveZ]);
                    
                end
            end
            sTime = 0;
            for ii = 1:obj.numFrames
                imageFilePrefixName = fullfile(imageFolderPath, append("frame_", num2str(ii)));
                imageFileName = append(imageFilePrefixName,  ".mat");
                
                % We set the shutter open/close successively
                % for each frame of the capture, even if we don't
                % render a frame, as we might need to render subsequent
                % frames
                obj.thisR.set('shutteropen', sTime);
                sTime = sTime + obj.expTimes(ii);
                obj.thisR.set('shutterclose', sTime);
                
                %IF we haven't rendered before, do it now
                if ~isfile(imageFileName)
                    
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
                    % There is some problem here I think, as scenes that
                    % have been previously generated show up without the
                    % correct FOV. So maybe we need to set that here, but
                    % where else is it set?
                    sceneObject = sceneFromFile(imageFileName, 'multispectral');
                end
                if ~exist('sceneObjects', 'var')
                    sceneObjects = {sceneObject};
                else
                    sceneObjects(end+1) = {sceneObject};
                end
                sceneFiles = [sceneFiles imageFileName]; %#ok<AGROW>
                
            end
            
            
        end
        
        function previewScene = preview(obj)
            % get a preview that the camera can use to plan capture
            % settings
            [previewScene, previewFiles] = obj.render( .1); % generic exposure time
            % delete any image files that were created
            % except we are deleting them all :(
            % need to fix that!
            for ii = 1:numel(previewFiles)
                if isfile(previewFiles(ii)) delete(previewFiles(ii)); end
            end
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

