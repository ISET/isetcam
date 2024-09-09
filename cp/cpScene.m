classdef cpScene < handle
    %cpScene Computational enhancement of scene struct
    %   Allows for computed scenes, that can include
    %   camera motion and motion of objects in the scene
    %
    %   For full functionality, accepts a PBRT scene from
    %   which it can generate a series of usable scenes or ois,
    %   either as a scene name, or as a Recipe
    %
    %   Can also accept ISET scenes (.mat), but
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
    %           'iset scenes'  -- previously-loaded ISET scene struct(s)
    %           For now these just handle single instances:
    %           'iset scene files'   -- an ISET scene file(s)
    %           'iset scene files'   -- an ISET scene file(s)
    %           'image files'  -- image file name(s)
    %           'sceneLuminance' -- light level of the rendered scenes
    %
    % History:
    %   Initial Version: D. Cardinal 12/2020
    %
    % Sample Code:
    %   load the Cornell Box + Stanford bunny
    %   set up for moving the bunny
    %   then generate a series of scenes based on that
    %{
    	ourScene = cpScene();
        ourScene.initialScene = <name of cb_bunny pbrt resource>
        ourScene.cameraMotion = [0 0 0];
        % bunny is currently labeled Default_B
        ourScene.objectMotion = {{'Bunny_O', [1 0 0], [0 0 0]}};
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
        isetScenes = {};
        isetSceneFileNames = [];
        imageFileNames = [];

        thisR = [];
        thisD = [];

        scenePath;  % defaults set in constructor if needed
        sceneName;

        resolution; % set in constructor
        numRays; % set in constructor

        %numFrames & expTimes are currently over-defined
        %as we compute nF from eT, but leaving both here for possible TBA
        numFrames; % Set in constructor
        expTimes = [.5];    % single or array of exposure times to use when
        % generating the rendered images

        % we have two types of camera motion
        % 1) Translate & Rotate per frame
        % 2) ActiveTranform for motion during frame
        useActiveCameraMotion = false;

        % See if we can use this for both 'active' & 'passive'
        % ['<cameraname>' [tx ty tz] [rx ry rz]]
        cameraMotion = []; % extent of camera motion in meters per second

        allowsObjectMotion = false; % default until set by scene type
        objectMotion = []; % none until the user adds some

        lensFile = '';   % Since PBRT can accept lens models and return an OI
        filmDiagonal;
        apertureDiameter = []; % passed when using a lens file. in mm.
        % provide the option to specify one here. In this
        % case, instead of returning an array of scenes, we
        % return an array of oi's, that can be fed directly
        % to a sensor. Default is simple "pinhole"
        %{
            lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
            thisR.camera = piCameraCreate('omni','lensFile',lensfile);
        %}

        sceneLuminance; % set in constructor, helps simulate lighting
        cachedRecipeFileName = '';
        originalRecipeFileName = ''; % to put back after we stash copies
        clearTempFiles = true; % by default remove our copy of pbrt scenes after use

        focusRange = []; % for when we do focus stacking
        % right now we calculate automatically, but should allow it to be
        % passed in as well

        verbosity = getpref('docker','verbosity',1); % level of chattiness
    end

    %% Do the work here
    methods
        function obj = cpScene(sceneType, options)
            arguments
                sceneType (1,1) string;
                options.recipe struct = struct([]);
                options.sceneName char = 'cornell box bunny chart';
                options.scenePath char = 'Cornell_BoxBunnyChart';
                options.resolution (1,2) {mustBeNumeric} = [1024 1024];
                options.numRays (1,1) {mustBeNumeric} = 64;
                options.numFrames (1,1) {mustBeNumeric} = 1;
                options.imageFileNames (1,:) string = [];
                options.isetScenes (1,:) struct = [];
                options.isetSceneFileNames (1,:) string = [];
                options.initialScene (1,:) struct = ([]);
                options.lensFile char = '';
                options.filmDiagonal = 44;
                options.sceneLuminance (1,1) {mustBeNumeric} = 0;
                options.waveLengths {mustBeNumeric} = [400:10:700];
                options.dispCal char = 'OLED-Sony.mat';
                options.apertureDiameter {mustBeNumeric} = [];
                options.verbose {mustBeNumeric} = 0; % squash output by default
                options.useActiveCameraMotion = true;
                options.allowsObjectMotion = false;
                options.thisD = [];
            end
            obj.resolution = options.resolution;
            obj.numRays = options.numRays;
            obj.numFrames = options.numFrames;
            obj.lensFile = options.lensFile;
            obj.filmDiagonal = options.filmDiagonal; % sensor mm           obj.sceneLuminance = options.sceneLuminance;
            obj.apertureDiameter = options.apertureDiameter;
            obj.verbosity = options.verbose;
            obj.sceneLuminance = options.sceneLuminance;
            obj.useActiveCameraMotion = options.useActiveCameraMotion;
            obj.thisD = options.thisD;

            %cpScene Construct an instance of this class
            %   allow whatever init we want to accept in the creation call
            obj.sceneType = sceneType;
            switch obj.sceneType
                case 'recipe' % we can pass a recipe directly if we already have one loaded
                    if exist(options.recipe,'var')
                        obj.thisR = options.recipe;
                        if ~isempty(obj.lensFile)

                            obj.thisR.camera = piCameraCreate('omni',...
                                'lensFile',obj.lensFile);
                            obj.thisR.set('film diagonal', obj.filmDiagonal); % sensor mm

                        end
                        obj.allowsObjectMotion = true;
                    else
                        error("For recipe, need to pass in an object");
                    end
                case 'pbrt' % pass a pbrt scene
                    obj.scenePath = options.scenePath;
                    obj.sceneName = options.sceneName;

                    if ~piDockerExists, piDockerConfig; end

                    try
                        obj.thisR = piRecipeCreate(obj.sceneName);
                    catch
                        obj.thisR = piRead(which([obj.sceneName '.pbrt']), 'exporter', 'Copy');
                    end

                    if ~isempty(options.lensFile)
                        obj.thisR.camera = piCameraCreate('omni',...
                            'lensFile',obj.lensFile);
                    else
                        obj.thisR.camera = piCameraCreate('perspective');
                    end
                    obj.thisR.set('film diagonal',obj.filmDiagonal); % sensor mm
                    obj.allowsObjectMotion = true;
                    % ideally we should be able to accept an array of scene
                    % files
                case 'iset scene files'
                    obj.isetSceneFileNames = options.isetSceneFileNames;
                    % hack just to see if we can process one scene
                    % assume ISET scenes are multispectral, fwiw.
                    obj.isetScenes = [];
                    for ii = 1:numel(obj.isetSceneFileNames)
                        obj.isetScenes = [obj.isetScenes sceneFromFile(obj.isetSceneFileNames(ii), 'multispectral',...
                            [], options.dispCal)];
                    end
                    obj.sceneType = 'iset scenes'; % Since we have now loaded our files into scenes
                case 'iset scenes'
                    obj.isetScenes = options.isetScenes;
                case 'images'
                    obj.isetScenes = [];
                    obj.imageFileNames = options.imageFileNames;
                    for ii = 1:numel(options.imageFileNames)
                        obj.isetScenes = [obj.isetScenes sceneFromFile(convertStringsToChars(options.imageFileNames(ii)), 'rgb', ...
                            [], options.dispCal, options.waveLengths)];
                    end
                    obj.sceneType = 'iset scenes'; % as we now have scene files
                otherwise
                    error("Unknown Scene Type");
            end

        end

        %% Main rendering function
        % We know the scene, but need to pass Exposure Time(s),
        % which also gives us numFrames
        % TODO: If there is no camera or object motion, then for burst &
        % stack operations, maybe we should just render once in pbrt to
        % save time?
        function [sceneObjects, sceneFiles, renderedFiles] = render(obj,expTimes, options)
            arguments
                obj cpScene;
                expTimes (1,:);
                options.focusDistances = [];
                options.previewFlag (1,1) {islogical} = false;
                % reRender is tricky. You can use it if you are sure
                % you haven't changed anything in the recipe since last
                % time

                options.reRender (1,1) {islogical} = true;
                options.filmSize {mustBeNumeric} = 4; % default
            end
            obj.numFrames = numel(expTimes);
            obj.expTimes = expTimes;
            % render uses what we know about the initial
            % image and subsequent motion requests
            % to generate one or more output scene or oi structs

            %   If lensmodel is set, in future it will be used with PBRT and
            %   we return an array of oi objects, otherwise scenes
            %   FUTURE

            renderedFiles = [];
            if exist('sceneObjects', 'var'); clear(sceneObjects); end
            % Process based on sceneType.
            switch obj.sceneType
                case {'pbrt', 'recipe'}
                    if ~piDockerExists, piDockerConfig; end
                    % read scene (defaults is cornell box with bunny)
                    if isempty(obj.thisR)
                        obj.thisR = piRecipeDefault('scene name', obj.sceneName);
                        % Okay, if we have a lensFile, we need to reapply it here
                        % but it doesn't seem to work?
                        if ~isempty(obj.lensFile)
                            obj.thisR.camera = piCameraCreate('omni','lensFile',obj.lensFile);
                        else
                            obj.thisR.camera = piCameraCreate('perspective');
                        end
                    end

                    %% We need to write a copy of the recipe in its default
                    % location also, for future processing

                    piWrite(obj.thisR);


                    % Modify the film resolution
                    % FIX: This should be set to the sensor size, ideally
                    % or maybe to a fraction for faster performance
                    val = recipeSet(obj.thisR,'filmresolution', obj.resolution);
                    val = recipeSet(obj.thisR,'rays per pixel',obj.numRays);
                    val = recipeSet(obj.thisR,'film diagonal', round(options.filmSize *1.5));

                    %% Don't add our own light here
                    % scene needs one before we are called
                    imageFolderPath = fullfile(isetRootPath, 'local', obj.scenePath, 'images');
                    if ~isfolder(imageFolderPath)
                        mkdir(imageFolderPath);
                    end
                    sceneFiles = [];

                    % Okay we have object motion & numframes
                    % but if Motion doesn't work, then we need to translate between
                    % frames

                    % process object motion if allowed
                    if obj.allowsObjectMotion & ~isempty(obj.objectMotion)
                        for ii = 1:numel(obj.objectMotion.transform)
                            ourMotion = obj.objectMotion.transform{ii};
                            if ~isempty(ourMotion{1})
                                %obj.thisR.set('asset', ourMotion{1}, 'motion', 'translation', ourMotion{2});
                                %obj.thisR.set('asset', ourMotion{1}, 'motion', 'rotation', ourMotion{3});

                                if ~isempty(obj.thisR.get('asset',ourMotion{1},'motion'))
                                    obj.thisR.set('asset', ourMotion{1}, 'motion', []);         
                                end
                                % NOTE: Clearing motion _doesn't_ clear
                                %       translation and rotation currently
                                %{
                                if ~isempty(obj.thisR.get('asset',ourMotion{1},'translation'))
                                    obj.thisR.set('asset', ourMotion{1}, 'translation', []);         
                                end
                                if ~isempty(obj.thisR.get('asset',ourMotion{1},'rotation'))
                                    obj.thisR.set('asset', ourMotion{1}, 'rotation', []);         
                                end
                                %}
                                % NOTE: sending 0 seems to confuse
                                % piGeometryWrite, so check for useful
                                % values
                                if ~isequal(ourMotion{2},[0 0 0])
                                    piAssetMotionAdd(obj.thisR,ourMotion{1}, ...
                                        'translation', ourMotion{2});
                                end
                                if ~isequal(ourMotion{3},[0 0 0])
                                    piAssetMotionAdd(obj.thisR,ourMotion{1}, ...
                                        'rotation', ourMotion{3});
                                end
                            
                            end
                            %thisR.set('asset', bunnyName, 'translation', [moveX, moveY, moveZ]);

                        end
                    end

                    sTime = 0;
                    % used to be focus distances, but those are broken
                    % so try this:
                    for ii = 1:numel(expTimes)
                        imageFilePrefixName = fullfile(imageFolderPath, sprintf("frame_%05d", num2str(ii)));
                        %Some camera subtypes use focal (internal)
                        % and some use focus (external)
                        switch (obj.thisR.camera.subtype)
                            case {'pinhole', 'perspective'}
                                % try the default
                                %defaultPinholeFocal = .1; % should probably be allowed to pass?
                                %obj.thisR.set('focaldistance', defaultPinholeFocal);
                                %if isfield(obj.thisR.camera, 'focusdistance')
                                %    obj.thisR.camera = rmfield(obj.thisR.camera, 'focusdistance');
                                %end
                            case {'omni', 'realistic'}
                                if isempty(options.focusDistances) || numel(options.focusDistances) < ii || isempty(options.focusDistances(ii))
                                    options.focusDistances(ii) = 5; % meters default
                                end
                                obj.thisR.set('focusdistance', options.focusDistances(ii));
                                if isfield(obj.thisR.camera, 'focaldistance')
                                    obj.thisR.camera = rmfield(obj.thisR.camera, 'focaldistance');
                                end
                        end

                        imageFileName = append(imageFilePrefixName,  ".mat");

                        % We set the shutter open/close successively
                        % for each frame of the capture, even if we don't
                        % render a frame, as we might need to render subsequent
                        % frames
                        obj.thisR.set('shutteropen', sTime);
                        % Try deliberately setting active transform times
                        % But the transforms are per second so maybe 0 to
                        % 1?
                        obj.thisR.set('transformtimesstart',sTime);
                        sTime = sTime + max(.001, obj.expTimes(ii));
                        obj.thisR.set('shutterclose', sTime);
                        obj.thisR.set('transformtimesend',sTime);

                        % process camera motion if allowed
                        % We do this per frame because we want to
                        % allow for some perturbance/shake/etc.

                        if ~isempty(obj.cameraMotion)
                            movePBRTCamera(obj, ii);
                        end
                        %
                        %% Render and visualize
                        % we don't want to trip over ourselves by
                        % over-writing the primary copy in local and then
                        % having other bits of code use it. So TBD is
                        % unique naming & then deletion. Annoying &
                        % expensive, but for now?...

                        % okay, this was annoying locally, but fatal when
                        % we have a rendering server! So back to the old
                        % way of overwriting the main copy

                        [defaultRecipeDirectory, defaultRecipeFile, suffix] = ...
                            fileparts(recipeGet(obj.thisR, 'outputfile'));

                        obj.cachedRecipeFileName = fullfile(tempname(defaultRecipeDirectory), strcat(defaultRecipeFile,suffix));
                        obj.originalRecipeFileName = recipeGet(obj.thisR, 'outputfile');
                        recipeSet(obj.thisR, 'verbose', 0);
                        %                        recipeSet(obj.thisR, 'outputfile', obj.cachedRecipeFileName);
                        tic % let's see how much overhead is the copy
                        piWrite(obj.thisR, 'verbose', 0); % pbrt reads from disk files so we need to write out
                        toc
                        haveCache = false;

                        % Haven't found a good way to cache, so we've added
                        % a reRender flag to override regenerating scenes
                        if options.reRender == true && haveCache == false
                            rName = obj.thisR; % Save doesn't like dots?
                            % by default also calc depth, could make that
                            % an option:

                            obj.thisR.set('filmrendertype',{'radiance','depth'});
                            [sceneObject, results, ~, renderedFile] = piRender(obj.thisR,  ...
                                'verbose', obj.verbosity, 'docker', obj.thisD);

                            [p, n, e] = fileparts(renderedFile);
                            sequencedFileName = fullfile(ivDirGet('computed'), sprintf('%s-%03d-%03d%s',n,ii,round(1000*obj.expTimes(ii)), e));
                            movefile(renderedFile, sequencedFileName,'f');
                            renderedFiles{end+1} = sequencedFileName;
                        else
                            sceneObject = sceneFromFile(imageFileName, 'multispectral');
                        end
                        recipeSet(obj.thisR, 'outputfile', obj.originalRecipeFileName);
                        %if obj.clearTempFiles && isfile(obj.cachedRecipeFileName)
                        %    rmdir(fileparts(obj.cachedRecipeFileName), 's');
                        %end

                        if isequal(sceneObject.type, 'scene') && haveCache == false
                            % for debugging
                            if obj.sceneLuminance > 0
                                sceneObject = sceneSet(sceneObject,'meanluminance', obj.sceneLuminance);
                            end
                            %sceneWindow(sceneObject);
                            sceneToFile(imageFileName,sceneObject);
                            % this is mostly just for debugging & human inspection
                            %rgbImage = sceneShowImage(sceneObject,-3); % HDR, no render
                            %imwrite(rgbImage,imageFilePrefixName)
                            %sprintf("Scene luminance is: %f", sceneGet(sceneObject, 'mean luminance'));
                        elseif isequal(sceneObject.type, 'opticalimage') % we have an optical image
                            oiSaveImage(sceneObject, append(imageFilePrefixName,'.png'));
                            save(imageFileName,'sceneObject');
                            oiWindow(sceneObject);
                        else
                            error("Render seems to have failed.");
                        end

                        if ~exist('sceneObjects', 'var')
                            sceneObjects = {sceneObject};
                        else
                            sceneObjects(end+1) = {sceneObject};
                        end
                        sceneFiles = [sceneFiles imageFileName];
                    end

                case 'iset scenes'
                    sceneFiles = [];
                    if options.previewFlag && numel(expTimes) > 1
                        expTimes = expTimes(1); % no need for more than one when previewing
                    end

                    % we want to generate scenes as needed
                    if numel(expTimes) == numel(obj.isetScenes)
                        % there has got to be a simpler way!
                        sceneObjects = {};
                        for ii = 1:numel(expTimes)
                            sceneObjects{end+1} = obj.isetScenes(ii); %#ok<AGROW>
                        end
                    elseif numel(expTimes) > 1 && numel(obj.isetScenes) > 1
                        error("If you pass multiple scenes to cpScene, they need to match up with Exposure Times.");
                    elseif numel(expTimes) > 1
                        %% Here is the case where we need to add camera motion
                        % we just have one scene so multiply it out
                        if ~isempty(obj.cameraMotion)
                            movedScene = obj.isetScenes;
                            sceneObjects = {};
                            for ii = 1:numel(expTimes)
                                sceneObjects{end+1} = movedScene; %#ok<AGROW>
                                movedScene = moveISETCamera(obj, movedScene, obj.cameraMotion);
                            end

                        else
                            % without camera motion!
                            sceneObjects = num2cell(repmat(obj.isetScenes, 1, numel(expTimes)));
                        end
                    elseif numel(expTimes) == 1
                        % We have an array of scenes, so extend our
                        % exposure time array to match
                        obj.expTimes = repmat(expTimes, 1, numel(obj.isetScenes));
                        % there has got to be a simpler way!
                        sceneObjects = {};
                        for ii = 1:numel(expTimes)
                            sceneObjects{end+1} = obj.isetScenes(ii); %#ok<AGROW>
                        end
                    else
                        error("Unknown scene parameters");
                    end
                    % we can only do camera motion by moving the scene.
                case 'image files'
                    % single base image or array of images
                otherwise
                    error("unsupported scene type");
            end
        end

        function movePBRTCamera(obj, frameNumber)

            persistent rotationMatrixStart;
            persistent rotationMatrixEnd;

            % unless we are allowing active motion
            % the first frame doesn't move
            if isequal(frameNumber, 1)
                if ~obj.useActiveCameraMotion
                    return;
                else
                    rotationMatrixStart = piRotationMatrix;
                    rotationMatrixEnd = piRotationMatrix;
                end
            end
            for ii = 1:numel(obj.cameraMotion)
                ourMotion = obj.cameraMotion{ii};

                % New way is to use activetransform
                if obj.useActiveCameraMotion
                    if ~isempty(ourMotion{2})

                        translationEnd = ourMotion{2}(:)';  % meters

                        obj.thisR.set('camera motion translate start',[0 0 0]);
                        obj.thisR.set('camera motion translate end',translationEnd);

                    end
                    % If we have shutter times, then maybe we can send in
                    % the "full" rotation and let pbrt do the work of
                    % only processing the portion while the shutter is open
                    if ~isempty(ourMotion{3})

                        % Start where we left off -- OR NOT!
                        %rotationMatrixStart = rotationMatrixEnd;
                        rotationMatrixEnd(1,1) = rotationMatrixStart(1,1) ...
                            + ourMotion{3}(3);
                        rotationMatrixEnd(1,2) = rotationMatrixStart(1,2) ...
                            + ourMotion{3}(2);
                        rotationMatrixEnd(1,3) = rotationMatrixStart(1,3) ...
                            + ourMotion{3}(1);

                        obj.thisR.set('camera motion rotate start',rotationMatrixStart);
                        obj.thisR.set('camera motion rotate end',rotationMatrixEnd);

                    end
                else % non active
                    if ~isempty(ourMotion{2})
                        obj.thisR = piCameraTranslate(obj.thisR, ...
                            'x shift', ourMotion{2}(1),...
                            'y shift', ourMotion{2}(2),...
                            'z shift', ourMotion{2}(3));  % meters
                    end
                    if ~isempty(ourMotion{3})
                        obj.thisR = piCameraRotate(obj.thisR,...
                            'x rot', ourMotion{3}(1),...
                            'y rot', ourMotion{3}(2),...
                            'z rot', ourMotion{3}(3));
                    end
                end
            end
        end

        % we don't really move the camera, but we can move the scene
        function movedScene = moveISETCamera(obj, existingScene, moveCamera)
            arguments
                obj cpScene;
                existingScene struct;
                moveCamera;
            end

            % We need to make sure all our returned scenes are the same
            % dimensions as our original, or they can't be merged later
            origSize = size(existingScene.data);

            %motionHDegrees = 2;
            %motionVDegrees = 0.3;
            if isempty(moveCamera)
                movedScene = existingScene;
                return; % nothing to do
            end
            %Assume for now the caller only has one motion argument
            %for ii = 1:numel(obj.cameraMotion)
            ourMotion = moveCamera{1};
            if ~isempty(ourMotion{2})
                movedScene = sceneTranslate(existingScene, ...
                    ourMotion{2}, sceneGet(existingScene, 'mean luminance'));
            else
                movedScene = existingScene;
            end
            if ~isempty(ourMotion{3})
                tmpScene = movedScene; % need to copy or it locks up...
                movedScene = sceneRotate(tmpScene, ...
                    ourMotion{3}(1));
            end
            % make sure dimensions match
            %movedScene = resize(movedScene.data, origSize);
            %end

            %Some code for when we want to put back "random" motion
            %             tScene = scene; % initial Seed
            %             % translation wants degrees
            %             motionArray = genMotion(motionHDegrees, motionVDegrees, obj.numFrames); % Set large to see effect
            %
            %             for ii = 1:obj.numFrames
            %                 % simple motion model where user tries to keep initial
            %                 % position but is off by a random amount each time
            %                 tScene = sceneTranslate(scene, motionArray(ii, :), sceneGet(scene, 'mean luminance'));
            %             end
        end

        % generate some random scene/camera motion
        function [motionArray] = genMotion(xPixels, yPixels, numFrames)
            motionArray = 2 * (rand(numFrames, 2)-.5) .* repmat([xPixels yPixels], numFrames, 1);
        end

        function [previewScenes, previewFiles] = preview(obj)
            % get a preview that the camera can use to plan capture
            % settings -- tricky setting the guesstimate to use
            % for the preview. IRL maybe ambient light or continuous
            % adjustment helps
            [previewScenes, previewFiles] = obj.render([.5], 'previewFlag', true); % generic exposure time
        end

        function infoArray = showInfo(obj)
            infoArray = {'Scene Type: ', obj.sceneType};
            infoArray = [infoArray; {'Scene Name:', obj.sceneName}];
            infoArray = [infoArray; {'Rays per pixel:', obj.numRays}];
            rez = sprintf("%d by %d",obj.resolution(1), obj.resolution(2));
            infoArray = [infoArray; {'Resolution:', rez}];
        end

        % remove the cached pbrt scene when we are destroyed
        function delete(obj)
            if isfile(obj.cachedRecipeFileName)
                [cacheDir, ~, ~] = fileparts(obj.cachedRecipeFileName);
                rmdir(cacheDir,'s');
            end
        end
    end
end

