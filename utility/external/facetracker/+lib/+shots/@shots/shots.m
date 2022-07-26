%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef shots < handle
    
    
    properties
	startFrames
	endFrames
    end

    methods

      function obj = shots()
            
            obj.startFrames = [];
            obj.endFrames = [];
      end
        
        
        detect(obj,video,outPath);
        hog = features(obj,img,cellsize);

        
        function [rhist, ghist] = computeRGHist(obj,im)
            rg = im(:,:,1:2)./repmat(sum(im, 3), [1,1,2]); % normalized rg
            rg_aux = rg(:,:,1);
            rhist = hist(rg_aux(:), 0:0.05:1)/numel(rg_aux);
            rg_aux = rg(:,:,2);
            ghist = hist(rg_aux(:), 0:0.05:1)/numel(rg_aux);
        end
        function loadFromPath(obj,path)
         
           data = load(path);
           obj.startFrames = data.startFrames;
           obj.endFrames = data.endFrames;
        end
        function loadFromPathAxes(obj,path,numFrames)
         
           filename = dir(sprintf('%s/*.scenecut',path));
           path = [path, filename.name];
           fp = fopen(path,'r');
           line = fgetl(fp);
           line = fgetl(fp);
           ele = regexp(line,'\ ','split');
           
           frames = [];
           frames(1) = 1;
           for i =1:numel(ele)
               if(~strcmp(ele{i},''))
                frames(end+1) = str2num(ele{i});
               end
           end
           frames(end+1) = numFrames+1;
           
           
           obj.startFrames = frames(1:end-1);
           obj.endFrames = frames(2:end)-1;
        end
        
    end

end
