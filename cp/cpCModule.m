classdef cpCModule
    %cpCModule Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 cpCModule per ciCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    %
    %   Note that if we are working with pbrt & a lens file
    %   then the CModule gets back an oi and ignores its own optics.
    
    % History:
    %   Initial Version: D.Cardinal 12/2020, iset3d-v4 port 12/2021

    % Work in Progress:
    %  Model complex sensors (like Samsung Corner Pixel)
    %  by simulating them as two sensors within one module
    %  or two modules within one camera
    %
    %  image combination should be done at the IP level
    %  for maximum flexibility, but could be in sensor for
    %  trivial HDR and stacking.
    
    properties
        oi; % optics plus their resulting image
        sensor;
        stabilizer = []; % for future use :)
        % for future, do user filters go here or in optics?
    end
    
    % Currently, many of the calls to us are just going to be passthrough
    % to either the sensor or optics structs, but not sure there is a
    % better way to deal with it that leaves existing code alone.
    
    methods
        function obj = cpCModule(options)
            %cpCModule Construct an instance of this class
            arguments
                % if we don't get sensor or oi passed in, use default
                options.sensor = sensorCreate('imx363');
                options.oi = oiCreate();
            end
            obj.sensor = options.sensor;
            obj.oi = options.oi;
            
        end
        
        % Based on the camera's focus settings we calculate focus distances
        % by querying the scene
        function [focusDistances, expTimes] = focus(obj, aCPScene, expTimes, focusMode, focusParam)
            if isequal(aCPScene.sceneType, 'pbrt') || isequal(aCPScene.sceneType, 'recipe')
                
                distanceRange = aCPScene.thisR.get('depthrange');

                % assume camera type for now
                %aCPScene.thisR.set('camera subtype','omni')
                % if we are focus stacking space out our focus
                % distances
                if isequal(focusMode, 'Stack')
                    focusFrames = focusParam;
                    % we want an evenly spaced set of distances from near
                    % to far
                    if distanceRange(1) == distanceRange(2)
                        focusDistances = repelem(distanceRange(1), focusParam);
                    else
                    focusDistances = [distanceRange(1):(distanceRange(2)-distanceRange(1))/(focusFrames-1):...
                        distanceRange(2)];
                    end
                    if numel(expTimes) < focusParam
                        expTimes = repelem(expTimes(1), focusParam);
                    end
                else
                    focusDistances = repelem((distanceRange(2) + distanceRange(1))/2, numel(expTimes));
                    expTimes = expTimes;
                end
                
            else % assume we only have an iset scene(s) and can use whatever distance(s) it/they have
                focusDistances = aCPScene.isetScenes(:).distance;
            end
        end
        
        function [cOutput, focusDistances] = compute(obj, aCPScene, expTimes, options) % will support more args
            %COMPUTE Calculate what we capture
            %   Simplest case this is sensorCompute + oiCompute
            %   however, we also integrate multi-capture
            %   including support for scenes that change during the
            %   burst or HDR capture
            
            %   For burst/bracket we (or our caller) use CScene to call PBRT (if we have an
            %   appropriate scene) to generate a set of scenes for us. Or
            %   we synthetically approximate motion from either a baseline
            %   ISET scene or image file. If given a burst of scenes or
            %   images, we assume they already incorporate motion.
            %
            %   TODO: If we load our lens model into PBRT, then it gives us
            %   an array of oi's, not scenes
            
            arguments
                obj cpCModule;
                aCPScene;
                expTimes;
                options.focusMode = 'Auto';
                options.focusParam = '';
                options.reRender {islogical} = true;
                options.stackFrames = 1;
                options.intent = 'Auto';
                options.fillFactors = [];
            end
             
            % need to know our sensor size to judge film size
            % however it is in meters and pi wants mm
            % but we need to make sure it is at least 1 for pbrt!
            filmSize = max(1, 1000 * sensorGet(obj.sensor, 'width'));
            % Render scenes as needed. Note that if pbrt has a lens file                                                                                    -
            % then 'sceneObjects' are actually oi structs                                                                                                          -
            
            [focusDistances, expTimes] = focus(obj, aCPScene, expTimes, options.focusMode, options.focusParam);
            
            % this assumes we want to stack if we have multiple
            % focus distances. What about video, though?
            if ~isequal(options.intent, 'Video') && options.stackFrames ~= numel(focusDistances)
                options.stackFrames = numel(focusDistances);
            end
            
            [sceneObjects, sceneFiles] = aCPScene.render(expTimes,...
                'focusDistances', focusDistances,...
                'reRender', options.reRender, 'filmSize', filmSize);
            
            cOutput = [];

            % store original pixel to restore later
            originalPixel = obj.sensor.pixel;
            pixelVoltSwing = pixelGet(originalPixel,'voltage swing');
            for ii = 1:numel(sceneObjects)
                
                ourScene = sceneObjects{ii};

                if strcmp(ourScene.type, 'scene')
                    if numel(focusDistances) > 1 && isequal(options.intent, 'FocusStack')
                        % DOESN'T WORK. Clearly doing something wrong:( DJC
                        % -- This is the "simple" case where we emulate
                        %    blur. The "advanced" case should use lens
                        %    files.
                        % we use defocus from depth here, especially needed
                        % for focus stacking if not done in pbrt. Need to
                        % add a way to pass focal distances.
                        imgPlaneDist = opticsGet(obj.oi.optics,'focal length');
                        multiplier = 1.01;
                        sceneDepth = max(ourScene.depthMap,[], 'all') - min(ourScene.depthMap,[], 'all');
                        sceneBands = 8;
                        depthEdges = min(ourScene.depthMap,[], 'all'): sceneDepth / sceneBands : max(ourScene.depthMap,[], 'all');
                        for iii = 1:options.stackFrames
                            [opticalImage, ~, ~] = s3dRenderDepthDefocus(ourScene, obj.oi, imgPlaneDist, depthEdges);
                            imgPlaneDist = imgPlaneDist*multiplier;
                            % set sensor FOV to match scene.
                            sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];
                            % this isn't right as it reduces resolution
                            %obj.sensor = sensorSetSizeToFOV(obj.sensor,sceneFOV,opticalImage);
                            oiWindow(opticalImage); % Check to see what they look like!
                        end
                    else
                        opticalImage = oiCompute(obj.oi, ourScene);
                        % set sensor FOV to match scene, but only once or
                        % we get multiple sizes, which don't merge
                        if ii == 1
                            sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];                            
                        end
                    end
                    
                elseif strcmp(ourScene.type, 'oi') || strcmp(ourScene.type, 'opticalimage')
                    % we already used a lens, so we got back an OI
                    opticalImage = ourScene;
                else
                    error("Unknown scene render");
                end
                % we have already calculated our exposure times
                obj.sensor = sensorSet(obj.sensor, 'exposure time', expTimes(ii));
                if ~isempty(options.fillFactors)
                    %obj.sensor = pixelCenterFillPD(obj.sensor, options.fillFactors(ii));
                    newSize = pixelGet(originalPixel,'pixel size') * options.fillFactors(ii);
                    obj.sensor.pixel = pixelSet(obj.sensor.pixel,'size ConstantFillFactor',newSize);
                    % Reducing fill factor reduces light received and pd
                    % size, but we also need to know a smaller well
                    % capacity
                    obj.sensor.pixel = pixelSet(obj.sensor.pixel,'voltageswing',pixelVoltSwing * options.fillFactors(ii));
                    if options.fillFactors(ii) < .5
                        % if small fill factor cheat and assume we want it in
                        % the corner
                        obj.sensor.pixel = pixelPositionPD(obj.sensor.pixel,'corner');
                    end
                end
                obj.sensor = sensorSet(obj.sensor, 'auto exposure', 0);
                % The OI returned from pbrt sometimes doesn't currently give us a
                % width or height, so we need to make something up:
                %% Hack -- DJC
                oiAngularWidth = oiGet(opticalImage,'wangular');
                if isempty(oiAngularWidth)
                    warning("No idea why we need to set wangular here!");
                    opticalImage = oiSet(opticalImage, 'wangular', .30);
                end
                sensorImage = sensorCompute(obj.sensor, opticalImage);
                cOutput = [cOutput, sensorImage]; %#ok<AGROW> 
                
                % put back original pixel voltage swing
                obj.sensor.pixel = originalPixel;

            end
        end
    end
end

