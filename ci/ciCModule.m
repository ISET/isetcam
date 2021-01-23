classdef ciCModule
    %CICMODULE Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 ciCModule per ciCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    %
    %   Note that if we are working with pbrt & a lens file
    %   then the CModule gets back an oi and ignores its own optics.
    
    % History:
    %   Initial Version: D.Cardinal 12/2020
    
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
        function obj = ciCModule(options)
            %CICMODULE Construct an instance of this class
            arguments
                % if we don't get sensor or oi passed in, use default
                options.sensor = sensorCreate();
                options.oi = oiCreate();
            end
            obj.sensor = options.sensor;
            obj.oi = options.oi;
            
        end
        
        function cOutput = compute(obj, sceneArray, exposureTimes, options) % will support more args
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
                obj ciCModule;
                sceneArray;
                exposureTimes;
                options.stackFrames {mustBeNumeric} = 0;
            end
            
            cOutput = [];
            for ii = 1:numel(sceneArray)
                
                ourScene = sceneArray{ii};
                if strcmp(ourScene.type, 'scene')
                    if options.stackFrames > 0
                        % we use defocus from depth here, especially needed
                        % for focus stacking if not done in pbrt. Need to
                        % add a way to pass focal distances.
                        % [oi, oiD, D] = s3dRenderDepthDefocus(scene, oi, imgPlaneDist, depthEdges, cAberration)
                        imgPlaneDist = opticsGet(obj.oi.optics,'focal length');
                        multiplier = 1.2; % go extreme to see effect
                        for iii = 1:options.stackFrames
                            [opticalImage, ~, ~] = s3dRenderDepthDefocus(ourScene, obj.oi, imgPlaneDist);
                            imgPlaneDist = imgPlaneDist*multiplier;
                            % set sensor FOV to match scene.
                            sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];
                            obj.sensor = sensorSetSizeToFOV(obj.sensor,sceneFOV,opticalImage);
                            oiWindow(opticalImage); % Check to see what they look like!
                        end
                    else
                        opticalImage = oiCompute(obj.oi, ourScene);
                        % set sensor FOV to match scene, but only once or
                        % we get multiple sizes, which don't merge
                        if ii == 1
                            sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];
                            obj.sensor = sensorSetSizeToFOV(obj.sensor,sceneFOV,opticalImage);
                        end
                    end
                    
                elseif strcmp(ourScene.type, 'oi') || strcmp(ourScene.type, 'opticalimage')
                    % we already used a lens, so we got back an OI
                    opticalImage = ourScene;
                    % this gets really broken, as our sensor shows a tiny
                    % FOV, so set size makes it massive resolution???'
                    oiFOV = [oiGet(opticalImage,'hfov'), oiGet(opticalImage,'vfov')];
                    obj.sensor = sensorSetSizeToFOV(obj.sensor,oiFOV,opticalImage);
                else
                    error("Unknown scene render");
                end
                obj.sensor = sensorSet(obj.sensor, 'exposure time', exposureTimes(ii));
                % The OI returned from pbrt sometimes doesn't currently give us a
                % width or height, so we need to make something up:
                %% Hack -- DJC
                oiAngularWidth = oiGet(opticalImage,'wangular');
                if isempty(oiAngularWidth)
                    warning("No idea why we need to set wangular here!");
                    opticalImage = oiSet(opticalImage, 'wangular', .30);
                end
                sensorImage = sensorCompute(obj.sensor, opticalImage);
                cOutput = [cOutput sensorImage]; %#ok<AGROW>
            end
        end
    end
end

