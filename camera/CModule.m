classdef CModule
    %CMODULE Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 CModule per CCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    
    properties
        oi; % optics plus their resulting image
        sensor;
        stabilizer; % for future use :)
    end
    
    % Currently, many of the calls to us are just going to be passthrough
    % to either the sensor or optics structs, but not sure there is a
    % better way to deal with it that leaves existing code alone.
    
    methods
        function obj = CModule(inputArg1,inputArg2)
            %CMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function cOutput = compute(obj,XXX)
            %COMPUTE Calculate what we capture
            %   Simplest case this is sensorCompute + oiCompute
            %   however, we also need to integrate multi-capture
            %   including support for scenes that change during the
            %   burst or HDR capture
            
            %! -- One biggish decision is whether to have the CModule
            %     directly support capturing bursts/brackets, or have 
            %     it called multiple times by the CCamera object (?)
            
        end
    end
end

