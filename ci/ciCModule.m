classdef ciCModule
    %CICMODULE Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 ciCModule per ciCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    
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
        
        function cOutput = compute(obj, sceneArray, exposureTimes) % will support more args
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
            
            cOutput = [];
            for ii = 1:numel(sceneArray)
                
                ourScene = sceneArray{ii};
                if strcmp(ourScene.type, 'scene')
                    opticalImage = oiCompute(obj.oi, ourScene);
                    % set sensor FOV to match scene.
                    if ii == 1 % just need to do this once, I think
                        sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];
                        obj.sensor = sensorSetSizeToFOV(obj.sensor,sceneFOV,opticalImage);
                    end
                    
                elseif strcmp(ourScene.type, 'oi') || strcmp(ourScene.type, 'opticalimage')
                    % we already used a lens, so we got back an OI
                    opticalImage = ourScene;
                    oiFOV = [oiGet(ourScene,'hfov'), oiGet(ourScene,'vfov')];
                    obj.sensor = sensorSetSizeToFOV(obj.sensor,oiFOV,ourScene);
                else
                    error("Unknown scene render");
                end
                obj.sensor = sensorSet(obj.sensor, 'exposure time', exposureTimes(ii));
                % The OI returned from pbrt doesn't currently give us a
                % width or height, so we need to make something up:
                %% Hack -- DJC
                oiAngularWidth = oiGet(opticalImage,'wangular'); 
                if isempty(oiAngularWidth)
                    opticalImage = oiSet(opticalImage, 'wangular', .30);
                end
                sensorImage = sensorCompute(obj.sensor, opticalImage);
                cOutput = [cOutput sensorImage]; %#ok<AGROW>
            end
        end
    end
end

