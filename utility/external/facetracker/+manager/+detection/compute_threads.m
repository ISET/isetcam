function compute_threads(videoPath,shotsPath)

    video = lib.data.video(videoPath);
    
    shots = lib.shots.shots();
    shots.loadFromPath(shotsPath);
    
    threadProc = lib.shots.shotThreads();
    threadProc.process(video,shots);
    
    
end