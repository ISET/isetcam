function doAlign(obj)
            
            [shotStart] = [obj.shots.startFrame];
            [shotEnd] = [obj.shots.endFrame];
        
            if(1)
            n = numel(obj.subtitles);
            m = numel(obj.transcript);
            subs_tokens = cell(n, 1);
            scripts_tokens = cell(m, 1);
            for i=1:n
                if(~isempty(obj.subtitles(i).text))
                    subs_tokens{i} = obj.line2tokens(obj.subtitles(i).text);
                end
            end;
            
            for j=1:m
                if(~isempty(obj.transcript(j).text))
                    scripts_tokens{j} = obj.line2tokens(obj.transcript(j).text);
                end
            end;
            
            A = zeros(n, m);
            for i=1:n
                for j=1:m
                    fprintf('%05d,%05d\r',i,j);
                    A(i,j) = obj.lineSim(subs_tokens{i}, scripts_tokens{j});
                end;
            end;
            
            seq2idxs = obj.dtw(A); % indexes of seq2 that are mapped to 1:n of sequence 1.
            else
                load aligned_indices;
            end
            for i=1:numel(seq2idxs)
                obj.subtitles(i).speaker = obj.transcript(seq2idxs(i)).speaker;
                obj.transcript(seq2idxs(i)).startFrame = obj.subtitles(i).startFrame;
                obj.transcript(seq2idxs(i)).endFrame = obj.subtitles(i).endFrame;
                obj.transcript(seq2idxs(i)).aligned = true;
                obj.transcript(seq2idxs(i)).shots = obj.subtitles(i).shots;
            end
            
            
            %% To Do Fix later add boundary conditions.
            for i=2:numel(obj.transcript)-1
                if(~obj.transcript(i).aligned)
                   %% Case 1: Both previous and next elements aligned 
                   if(obj.transcript(i-1).aligned && obj.transcript(i+1).aligned)
                       
                       %% Current transcript is a description of next.
                       if(abs(obj.transcript(i-1).endFrame - obj.transcript(i+1).startFrame)<=5)
                            obj.transcript(i).aligned = true;
                            obj.transcript(i).startFrame = obj.transcript(i+1).startFrame;
                            obj.transcript(i).endFrame = obj.transcript(i+1).endFrame;
                            obj.transcript(i).shots = obj.transcript(i+1).shots;
                       else
                       %% Current transcript probably belongs to shots in between.
                            obj.transcript(i).aligned = true;
                            obj.transcript(i).startFrame = obj.transcript(i-1).endFrame;
                            obj.transcript(i).endFrame = obj.transcript(i+1).startFrame;
                            if(~isempty(obj.transcript(i-1).shots) && ~isempty(obj.transcript(i+1).shots))
                                obj.transcript(i).shots = [obj.transcript(i-1).shots(end)+1:obj.transcript(i+1).shots(1)-1];
                            end
                            
                       end
                   end
                   
                   
                   
                end
            end
            
            aligned = [obj.transcript.aligned];
            ts = [1:numel(aligned)];
            idx = 2;
            while idx<numel(obj.transcript)-1
                 if(~obj.transcript(idx).aligned)
                     
                    
                    nextIdx = min(find(aligned & ts>idx));
                    prevIdx = max(find(aligned & ts<idx));
                    
                    
                    if(isempty(prevIdx) || isempty(nextIdx))
                        idx = idx+1;
                        continue;
                    end
                    
                    startFrame = obj.transcript(prevIdx).endFrame;
                    endFrame = obj.transcript(nextIdx).startFrame;
                    
                    startFrames = linspace(startFrame,endFrame,(nextIdx-prevIdx));
                    tidx = 1;
                    for j = prevIdx+1:nextIdx-1
                        
                        obj.transcript(j).aligned = true;
                        aligned(j) = true;
                        tStart = startFrames(tidx);
                        tEnd = startFrames(tidx+1);
                        
                        sidx = find(shotStart<=tStart & shotEnd>=tStart);
                        if(~isempty(sidx))
                            sidx = sidx(end);
                            obj.transcript(j).startFrame = obj.shots(sidx).startFrame;
                            obj.transcript(j).shots(end+1) = sidx;
                        end
                        
                        sidx = find(shotStart<=tEnd & shotEnd>=tEnd);
                        if(~isempty(sidx))
                            sidx = sidx(end);
                            obj.transcript(j).endFrame = obj.shots(sidx).endFrame;
                            obj.transcript(j).shots(end+1) = sidx;
                        end
                        if(~isempty(obj.transcript(j).shots))
                            obj.transcript(j).shots = unique(obj.transcript(j).shots);
                        end
                        
                        
                        tidx = tidx+1;
                    end
                    idx = nextIdx;
                 else
                     idx = idx +1;
                 end
            end
            
            obj.transcript(1).isSceneStart = true;
            obj.transcript(1).aligned = true;
            obj.transcript(1).shots  = 1;
            obj.transcript(1).startFrame = 1;
            

end