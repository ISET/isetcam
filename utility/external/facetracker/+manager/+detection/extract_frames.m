function extract_frames(inPath,outPath,framesPattern)


% mkdir(outPath);

video = lib.data.video(inPath);
frames = lib.data.video('');
frames.copyFrom(video);
frames.setPath(outPath);
frames.adjustWidthAR();

framesExtractor = lib.video_converters.frameExtractor();
framesExtractor.convertVideo(video,frames);


end
