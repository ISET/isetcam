function detect_shots(videoPath,outPath,outPathTxt)


video = lib.data.video(videoPath);
shots = lib.shots.shots();
shots.detect(video,outPath);

end