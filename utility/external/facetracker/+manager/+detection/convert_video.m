function convert_video(inPath,outPath)


mkdir(outPath);
video = lib.data.video(inPath);
mjpegVideo = lib.data.video('');
mjpegVideo.copyFrom(video);
mjpegVideo.setPath(outPath);
mjpegVideo.adjustWidthAR();
mjpegConverter = lib.video_converters.mjpegConverter();
mjpegConverter.convertVideo(video,mjpegVideo);
mjpegVideo.setExt('.avi');
mjpegVideo.gatherinfo();


end