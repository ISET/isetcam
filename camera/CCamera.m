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
                case {'Auto', 'Portrait', 'Scenic', 'Action', ...
                        'Pro', 'Night'}
                    % split these apart as they are implemented
                    % we might also want to add more "techie" intents
                    % like 'burst' rather than relying on them being
                    % activated based on some other user choice
                case 'HDR'
                    % use the bracketing code
                case 'otherwise'
                    error("Unknown photo intent");
            end
            
            function save(obj, sFileName)
                save(sFileName, obj);
            end
            
            function load(obj, lFileName)
                % how do we make sure this gets loaded into us
                % or should we just have an initializer that uses load?
                load(lFileName, obj)
            end
    end
end

