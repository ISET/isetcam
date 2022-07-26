function track_faces(videoPath,facePath,shotsPath,tracksPath,tracksProcessedPath)
%     video = lib.data.video(videoPath);
%     
%     shots = lib.shots.shots();
%     shots.loadFromPath(shotsPath);
%     
%     facedets = [];
%     load(facePath);
    
%     fc = [facedets.conf];
%     facedets = facedets(fc>=0.75);
%     tracker = lib.tracking.kltTracker();
%     facedets = tracker.track(video,shots,facedets,tracksPath);
%     save(tracksPath,'facedets');

    load(tracksPath,'facedets');
    tic
    trackprocessor = lib.tracking.postProcessor();
    facedets = trackprocessor.process(facedets);
    toc
    
    
    [trackids falsepositives] = trackprocessor.getFalsePositiveTracks(facedets);
    save(tracksProcessedPath,'facedets','trackids','falsepositives');
    
    
    end