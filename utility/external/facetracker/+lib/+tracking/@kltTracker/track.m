function facedets = track(obj,video,shots,dets,outPath)

    trackId = 0;
    frames = [dets.frame];
    trackDetsShot = {};
    for i=1:numel(shots.startFrames)
%     parfor i=1:numel(shots.startFrames)
        shotStart = shots.startFrames(i);
        shotEnd = shots.endFrames(i);
        idx = frames>=shotStart & frames<=shotEnd;
        if(~sum(idx)==0)
            trackDets = dets(idx);
            for j=1:numel(trackDets)
                trackDets(j).shot = i;
            end
            %fprintf('Shot %04d\n',i);
            [trackDetsShot{i},a] = obj.trackInShots(video,trackDets, shotStart, shotEnd, [],trackId);
        end
    end
    
    facedets = [];
    trackId = 0;
    for i=1:numel(trackDetsShot)
        td = trackDetsShot{i};
        if(~isempty(td))
            for j=1:numel(td)
                td(j).track =  td(j).track+trackId;
            end
            facedets = cat(2,facedets,td);
            trackId = max([td.track]);
        end
    end
    
    %facedets = cat(2,trackDetsShot{:});
    if(~isempty(outPath))
        save(outPath,'facedets');
    end
end