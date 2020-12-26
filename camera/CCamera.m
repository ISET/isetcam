classdef CCamera
    %CCAMERA Computational Camera
    %   Allows for more complex camera designs, potentially including:
    %   * Burst captures, including support for camera and object motion
    %   * More sophisticated ISP features
    %   *     including support for "Intents" provided by the user
    %   *     and potentially for multiple camera modules used for one
    %         photo
    
    properties
        cmodule; % 1 (or more) CModules
        isp;     % an ip     end
    
    methods
        function obj = CCamera(inputArg1,inputArg2)
            %CCAMERA Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = TakePicture(obj, 'scene', scene, 'intent', intent)
            %METHOD1 Main function telling us to create a photo
            switch intent
                case {'Auto', 'HDR', 'Portrait', 'Scenic', 'Action', ...
                        'Pro', 'Night'}
                    % split these apart as they are implemented

            end
    end
end

