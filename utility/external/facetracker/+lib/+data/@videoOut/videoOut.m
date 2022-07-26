%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef videoOut < handle
    
    
    properties
        aviobj 
    end

    methods

       function obj = videoOut(filePath)
       		obj.aviobj = VideoWriter(filePath,'Motion JPEG AVI');
            obj.aviobj.FrameRate =25; 
            obj.aviobj.Quality =95;
            open(obj.aviobj);
       end
        
       function addFrame(obj,frame)
            writeVideo(obj.aviobj,frame);
       end

       function close(obj)
            close(obj.aviobj);
       end
    end

	
end
