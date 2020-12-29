classdef ciCModule
    %CICMODULE Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 ciCModule per ciCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    
    % History:
    %   Initial Code: D.Cardinal 12/2020
    
    properties
        oi = oiCreate(); % optics plus their resulting image
        sensor = sensorCreate();
        stabilizer = []; % for future use :)
        % for future, do user filters go here or in optics?
    end
    
    % Currently, many of the calls to us are just going to be passthrough
    % to either the sensor or optics structs, but not sure there is a
    % better way to deal with it that leaves existing code alone.
    
    methods
        function obj = ciCModule()
            %CICMODULE Construct an instance of this class
            
            
        end
        
        function cOutput = compute(obj, sceneArray) % will support more args
            %COMPUTE Calculate what we capture
            %   Simplest case this is sensorCompute + oiCompute
            %   however, we also need to integrate multi-capture
            %   including support for scenes that change during the
            %   burst or HDR capture
            
            %   For burst/bracket we (or our caller) use CScene to call PBRT (if we have an
            %   appropriate scene) to generate a set of scenes for us.
            %
            %   IF we can load our lens model into PBRT, then it gives us
            %   an array of oi's, not scenes
            
            %! -- One biggish decision is whether to have the CModule
            %     directly support capturing bursts/brackets, or have 
            %     it called multiple times by the CCamera object (?)
            cOutput = [];
            for ii = 1:numel(sceneArray)
                opticalImage = oiCompute(obj.oi, sceneArray(ii)); 
                
                % set sensor FOV to match scene. I don't know if we should
                % always do this, or rely on the user to sort it out?
                if ii == 1 % just need to do this once, I think
                    sceneFOV = [sceneGet(sceneArray(ii),'fovhorizontal') sceneGet(sceneArray(ii),'fovvertical')];
                    obj.sensor = sensorSetSizeToFOV(obj.sensor,sceneFOV,opticalimage);
                end
                sensorImage = sensorCompute(obj.sensor, opticalImage);
                cOutput = [cOutput sensorImage];
            end
        end
    end
end

