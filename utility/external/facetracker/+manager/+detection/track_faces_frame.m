function track_faces_frame(framesPath,pattern,facePath,shotsPath,tracksPath)
    video = lib.data.videoFrames(framesPath,pattern);
    
    shots = lib.shots.shots();
    shots.loadFromPath(shotsPath);
    facedets = [];
    load(facePath);
    
    tracker = lib.tracking.kltTracker();
    facedets = tracker.track(video,shots,facedets,tracksPath);
    save(tracksPath,'facedets');
    trackprocessor = lib.tracking.postProcessor();
    facedets = trackprocessor.process(facedets);

    [trackids falsepositives] = trackprocessor.getFalsePositiveTracks(facedets);
    save(tracksPath,'facedets','trackids','falsepositives');
end