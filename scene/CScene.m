classdef CScene
    %CSCENE Computational enhancement of scene struct
    %   Allows for computed scenes, that can include
    %   camera motion and motion of objects in the scene
    %   
    %   For full functionality, accepts a PBRT scene from
    %   which it can generate a series of usable scenes for an oi
    %
    %   Can also accept ISET scenes (.mat) and images, but
    %   with reduced functionality
    %
    %   Can also retrieve a scene preview, as CCamera/CModule may rely on 
    %   that to make decisions about setting capture parameters
    
    properties
        initialscene;
    end
    
    methods
        function obj = CSene(inputArg1,inputArg2)
            %CSENE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = render(obj,XXX)
            % render uses what we know about the initial
            % image and subsequent motion requests
            % to generate one or more output scene objects
            
            %   Detailed explanation goes here
            
        end
        
        function outputArg = preview(obj, XXX)
            % get a preview that the camera can use to plan capture
            % settings
        end
    end
end

