classdef ciBurstCamera < ciCamera
    %CIBURSTCAMERA Sub-class of ciCamera that adds burst and bracketing
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = ciBurstCamera(varargin)
            %CIBURSTCAMERA Construct an instance of this class
            %   First invoke our parent ciCamera class
            obj = obj@ciCamera(varargin);

        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

