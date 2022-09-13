function track_faces_axes(videoPath,framesPattern,facePath,shotsPath,tracksPath)
    video = lib.data.videoFrames(videoPath,framesPattern);
    
    shots = lib.shots.shots();
    shots.loadFromPathAxes(shotsPath,video.frames);
    
    facedets = [];
    load(facePath);
    
    tracker = lib.tracking.kltTracker();
    facedets = tracker.track(video,shots,facedets,tracksPath);
    save(tracksPath,'facedets');

   % load(tracksPath,'facedets');
%     tic
     trackprocessor = lib.tracking.postProcessor();
     facedets = trackprocessor.process(facedets);
%     toc
%     
%     
    [trackids falsepositives] = trackprocessor.getFalsePositiveTracks(facedets);
    save(tracksPath,'facedets','trackids','falsepositives');
    
    
    end