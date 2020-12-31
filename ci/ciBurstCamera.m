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
        
       function ourPicture = TakePicture(obj, scene, intent)

            ourPicture = TakePicture@ciCamera(obj, scene, intent);
            % Typically we'd invoke the parent before or after us
            % or to handle cases we don't need to
            % Let's think about the best way to do that.
            % Otherwise could be some other type of specialized call?
            
        end
    end
end

