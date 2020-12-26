classdef CModule
    %CMODULE Camera module including sensor and optics
    %   wraps existing sensor and oi structs to allow
    %   control as a unit by a computational camera system
    %   initially we're supporting 1 CModule per CCamera,
    %   but as many camera systems now use several, we expect
    %   to support that in future.
    
    properties
        sensor;
        oi;
    end
    
    methods
        function obj = CModule(inputArg1,inputArg2)
            %CMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = compute(obj,XXX)
            %COMPUTE Calculate what we capture
            %   Simplest case this is sensorCompute + oiCompute
            %   however, we also need to integrate multi-capture
            %   including support for scenes that change during the
            %   burst or HDR capture
            outputArg = obj.Property1 + inputArg;
        end
    end
end

