function tracklet = interpolateTrack(obj,tracklet)
    
    frames = [tracklet.frame];
    uFrames = unique(frames);
    if(numel(uFrames)~=numel(frames))
        tempTracklet = {};
        for i=1:numel(uFrames)
           idx = find(frames==uFrames(i));
           idx = idx(1);
           tempTracklet{end+1} = tracklet(idx);
        end
        tracklet = cat(2,tempTracklet{:});
        frames = [tracklet.frame];
    end
    
    
    startFrame = min(frames);
    endFrame = max(frames);
    track_data = {};
    if (endFrame-startFrame)+1 ~= numel(frames)
        diff = frames(2:end) - frames(1:end-1);
        diff = diff-1;
        for i=1:numel(diff)
            if(diff(i)==0)
                frameData = tracklet(i);
                frameData.predicted = false;
                track_data{end+1} = frameData;
            else
                currFrameData = tracklet(i);
                currFrameData.predicted = false;
                track_data{end+1} = currFrameData;
                nextFrameData = tracklet(i+1);
                x1Pred = linspace(currFrameData.rect(1),nextFrameData.rect(1),diff(i)+2);
                y1Pred = linspace(currFrameData.rect(2),nextFrameData.rect(2),diff(i)+2);
                x2Pred = linspace(currFrameData.rect(3),nextFrameData.rect(3),diff(i)+2);
                y2Pred = linspace(currFrameData.rect(4),nextFrameData.rect(4),diff(i)+2);
                framePred = linspace(currFrameData.frame,nextFrameData.frame,diff(i)+2);
                pose = max([currFrameData.pose nextFrameData.pose]);
                pose = pose(1);
                trackconf = mean([currFrameData.trackconf nextFrameData.trackconf]);
                track = currFrameData.track;
                detConf = mean([currFrameData.conf nextFrameData.conf]);
                shot = currFrameData.shot;
                tracklength = currFrameData.tracklength;
                %shot_merged = currFrameData.shot_merged;
                for k=2:numel(framePred)-1
                   frame_data  = [] ;
                   frame_data.rect = [x1Pred(k) y1Pred(k) x2Pred(k) y2Pred(k)]';
                   frame_data.frame = framePred(k);
                   frame_data.trackconf =trackconf;
                   frame_data.conf =detConf;
                   frame_data.shot = shot;
                   frame_data.pose =pose;
                   frame_data.predicted = true;
                   frame_data.tracklength = tracklength;
                   frame_data.track = track;
                   %frame_data.shot_merged = shot_merged;
                   track_data{end+1} = frame_data;
                  
                end
                
                
                
                
            end
        end
        frameData = tracklet(end);
        frameData.predicted = false;
        track_data{end+1} = frameData;
        tracklet = cat(2,track_data{:});
        for i=1:numel(tracklet)
            tracklet(i).tracklength = numel(tracklet);
        end
    
    else
         for i=1:numel(tracklet)
                tracklet(i).predicted = false;
         end
    end
   
    
end