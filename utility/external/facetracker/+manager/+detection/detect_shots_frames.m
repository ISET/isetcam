function detect_shots_frames(framesPath,pattern,outPath)


video = lib.data.videoFrames(framesPath,pattern);
shots = lib.shots.shots();
shots.detect(video,outPath);

end