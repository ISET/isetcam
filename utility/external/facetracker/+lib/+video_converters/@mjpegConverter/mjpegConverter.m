%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef mjpegConverter < handle
    
    
    properties
        ffmpegPath
        ext
    end

    methods

        function obj = mjpegConverter()
            obj.ffmpegPath = '/users/omkar/local/bin/ffmpeg';
            obj.ext = '.avi';
        end
        
        function convertVideo(obj,source,dest)
           
            dest.setExt(obj.ext);
            
            for i=1:numel(source.files)
               cmdStr = sprintf('%s -i %s/%s%s -vcodec mjpeg -threads 1 -deinterlace -q:v 1 -vf scale=%d:%d %s/%s%s', ...
                   obj.ffmpegPath,source.path,source.files(i).name,source.files(i).ext,dest(i).files(i).width,dest.files(i).height, ...
                   dest.path,dest.files(i).name,dest.files(i).ext);
               system(cmdStr);
            end
        end
 
    end    
    

end
