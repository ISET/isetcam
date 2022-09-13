%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef frameExtractor < handle
    
    
    properties
        ffmpegPath
        ext
    end

    methods

        function obj = frameExtractor()
            obj.ffmpegPath = '/usr/bin/ffmpeg';
            obj.ext = '%08d.jpg';
        end
        
        function convertVideo(obj,source,dest)
           
            dest.setExt(obj.ext);
            
            for i=1:numel(source.files)
               cmdStr = sprintf('%s -i %s/%s%s -threads 1 -deinterlace -q:v 1 -vf scale=%d:%d %s/%s', ...
                   obj.ffmpegPath,source.path,source.files(i).name,source.files(i).ext,dest(i).files(i).width,dest.files(i).height, ...
                   dest.path,obj.ext);
               system(cmdStr);
            end
        end
 
    end    
    

end
