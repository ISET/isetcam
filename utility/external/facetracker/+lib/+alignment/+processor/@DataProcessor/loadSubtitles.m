function loadSubtitles(obj,subtitleFile)

    obj.subtitles = obj.subtitleParser.parseSubTitles(subtitleFile);
    
    if(~isempty(obj.shots))
       
        [shotStart] = [obj.shots.startFrame];
        [shotEnd] = [obj.shots.endFrame];
        
        
        
        
        for i=1:numel(obj.subtitles)
           subStart = obj.subtitles(i).startFrame+obj.matchInterval;
           subEnd = obj.subtitles(i).endFrame-obj.matchInterval;
           
           
           idx = find(shotStart<=subStart & shotEnd>=subStart);
           if(~isempty(idx))
               idx = idx(end);
               obj.subtitles(i).startFrame = obj.shots(idx).startFrame;
               obj.subtitles(i).shots(end+1) = idx;
           end
           
           idx = find(shotStart<=subEnd & shotEnd>=subEnd);
           if(~isempty(idx))
               idx = idx(end);
               obj.subtitles(i).endFrame = obj.shots(idx).endFrame;
               obj.subtitles(i).shots(end+1) = idx;
           end
           if(~isempty(obj.subtitles(i).shots))
                obj.subtitles(i).shots = unique(obj.subtitles(i).shots);
           end
           obj.subtitles(i).idx = i;
        end
        
    end

end