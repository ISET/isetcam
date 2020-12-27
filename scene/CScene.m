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
    %
    % History:
    %   Initial Version: D. Cardinal 12/20
    %
    % Sample Code:
    %   load the Cornell Box + Stanford bunny
    %   set up for moving the bunny
    %   then generate a series of scenes based on that
    %{
    	ourScene = Cscene();
        ourScene.initialScene = <name of cb_bunny pbrt resource>
        ourScene.cameraMotion = [0 0 0];
        % bunny is currently labeled Default
        ourScene.objectMotion = [['Default' [0 1 0] [0 0 0]]];
        ourScene.exposureTimes = [.5 .5 .5 .5];
        ourScene.cacheName = 'cb_bunny_slide';
    
        previewScene = ourScene.preview();
        renderedScenes = ourScene.render();
    %}
    
    properties
        initialScene; % Ideally this is a PBRT scene, but we also need
                      % to handle the case where it is an ISET scene
                      % or even just an image file
                      
        cameraMotion; % extent of camera motion in meters per second
                      % ['<cameraname>' [tx ty tz] [rx ry rz]]
                      
        objectMotion; % okay, this could be complicated.
                      % we have object names, translation, and rotation
                      % Seems like a good argument for being able to write
                      % out CScenes, that could encapsulate a "Setting"
                      % and then be re-used as test cases
                      % [['<objectname'] [tx ty tz] [rx ry rz]], repeat]
                      
         expTimes;    % single or array of exposure times to use when
                      % generating the rendered images
                      
         cacheName;   % Because scenes can be expensive to render, we
                      % store them in /local. But to use them as a cache
                      % we need to make sure they are relevant. We could
                      % do what we do with OI and match the entire setting
                      % structure, or here we just let the user "tag" a
                      % cache entry to see if they want to re-use it.
                      % individual scene frames are stored as files under
                      % this folder.
                      
    end
    
    methods
        function obj = CSene(inputArg1,inputArg2)
            %CSENE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function
            outputArg = render(obj,XXX)
            % render uses what we know about the initial
            % image and subsequent motion requests
            % to generate one or more output scene structs
            
            %   Detailed explanation goes here
            
        end
        
        function outputArg = preview(obj, XXX)
            % get a preview that the camera can use to plan capture
            % settings
        end
        
        function load(obj, cSceneFile)
            % load cScene data back in
            load(cSceneFile, obj);
        end
        
        function save(obj, cSceneFile)
            % write out cScene data for later re-use
            save(cSceneFile, obj);
        end
        
    end
end

