%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef video < handle
    
    
    properties
        files
        path 
        frames
        framesStart
        framesEnd
    end

    methods

        function obj = video(filePath)
            
            obj.files = [];
            obj.path = '';
            obj.frames = 0;
            obj.framesStart = [];
            obj.framesEnd = [];
            if(~isempty(filePath))
                if exist(filePath,'file') == 2
                    [path file ext] = fileparts(filePath);
                    obj.path = path;
                    obj.files(1).name = file;
                    obj.files(1).ext = ext;

                elseif exist(filePath,'dir') == 7
                    obj.path = filePath;
                    names = dir(filePath);
                    idx = 1;
                    for i=1:numel(names)
                        if(strcmp(names(i).name,'.') || strcmp(names(i).name,'..'))
                            continue;
                        end
                        [path file ext] = fileparts(names(i).name);
                        obj.files(idx).name = file;
                        obj.files(idx).ext = ext;
                        
                        idx = idx+1;
                    end
                else
                    error('Could not initialize video: %s\n',filePath); 
                end
                obj.gatherinfo();
            end
        end
        
        function gatherinfo(obj)
            for i=1:numel(obj.files)
                    
                    ffmpegPath = '/usr/bin/ffmpeg'; 
                    fullPath = sprintf('%s/%s%s',obj.path,obj.files(i).name,obj.files(i).ext);
                    command = sprintf('%s -i %s',ffmpegPath,fullPath);
                    [ign output] = system(command);
                    
                    elems = regexp(output,'\ ','split');
                    idx = find(strcmp(elems,'DAR'));
                    
                    if(~isempty(idx))
                        frameSizeStr = elems{idx-3};
                        darStr = elems{idx+1};
                        darStr = strtok(darStr,']');
                        
                        
                        telems = regexp(frameSizeStr,'x','split');
                        obj.files(i).width = str2num(telems{1});
                        obj.files(i).height = str2num(telems{2});
                        
                        telems = regexp(darStr,':','split');
                        obj.files(i).dar = str2num(telems{1})/str2num(telems{2});
                        
                        
                    else
                        obj.files(i).width = 16;
                        obj.files(i).height = 9;
                        obj.files(i).dar = 16/9;
%                         error('Cannot determine the aspect ratio');
                    end
            end
            
            for i=1:numel(obj.files)
                if(strcmp(obj.files(i).ext,'.avi'))
                    obj.files(i).reader = VideoReader(sprintf('%s/%s%s',obj.path,obj.files(i).name,obj.files(i).ext));
                    lastFrame = read(obj.files(i).reader, inf);
                    obj.files(i).frames = obj.files(i).reader.NumberOfFrames;
                    if(i==1)
                        obj.files(i).framesStart = 1;
                    else
                        obj.files(i).framesStart = obj.files(i-1).framesEnd+1;
                    end
                    obj.files(i).framesEnd = obj.frames + obj.files(i).frames;
                    
                    obj.framesStart(i) = obj.files(i).framesStart;
                    obj.framesEnd(i) = obj.files(i).framesEnd;
                    
                    obj.frames = obj.frames + obj.files(i).frames;
                end
            end
        end
        
        function adjustWidthAR(obj)
             for i=1:numel(obj.files)
                obj.files(i).width = obj.files(i).height*obj.files(i).dar;
             end
        end
        
        function copyFrom(obj,videoObj)
            obj.files = videoObj.files;
            obj.path = videoObj.path;
        end
        
        function setPath(obj,path)
           obj.path = path;
        end
        
        function setExt(obj,ext)
           for i = 1:numel(obj.files)
              obj.files(i).ext=ext; 
           end
        end
        
        frame = getFrame(obj,index);
    end

end
