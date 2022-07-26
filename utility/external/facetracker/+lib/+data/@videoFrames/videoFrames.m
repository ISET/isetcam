%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef videoFrames < handle
    
    
    properties
        files
        path
        frames
        pattern
    end
    
    methods
        
        function obj = videoFrames(filePath,pattern)
            
            obj.files = [];
            obj.path = '';
            obj.frames = 0;
            obj.pattern = [filePath '/' pattern];
            if exist(filePath,'file') == 2
                error('This reader cannot read from files');
            elseif exist(filePath,'dir') == 7
                obj.path = filePath;
            else
                error('Could not initialize videoFrames: %s\n',filePath);
            end
            obj.gatherinfo();
        end
        
        
        function gatherinfo(obj)
            
            names = dir(sprintf('%s/*',obj.path));
            obj.frames = numel(names)-2;
        end
        
        function adjustWidthAR(obj)
        end
        
        function copyFrom(obj,videoObj)
        end
        
        function setPath(obj,path)
            obj.path = path;
        end
        
        function setExt(obj,ext)
        end
        
        frame = getFrame(obj,index);
    end
    
end
