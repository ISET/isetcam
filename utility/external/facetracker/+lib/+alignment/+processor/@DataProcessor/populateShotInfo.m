function populateShotInfo(obj)
            
    for i=1:numel(obj.transcript)
       if(obj.transcript(i).aligned)
          for j=1:numel(obj.transcript(i).shots)
              shotId = obj.transcript(i).shots(j);
              
              if(~isempty(obj.transcript(i).description))
                obj.shots(shotId).description = sprintf('%s\n%s' ...
                    ,obj.shots(shotId).description,obj.transcript(i).description);
              end
              if(~isempty(obj.transcript(i).speaker))
                  obj.shots(shotId).speakers{end+1} = obj.transcript(i).speaker;
              end
              obj.shots(shotId).isSceneStart = obj.transcript(i).isSceneStart;
          end
       end
    end
            
    sceneId = 0;
    
    for i=1:numel(obj.shots)
       if(obj.shots(i).isSceneStart)
           sceneId = sceneId+1;
       end
       obj.shots(i).scene = sceneId;
    end
end