function plot_tracks(videoPath,tracksProcessedPath,outVideoPath)
    video = lib.data.video(videoPath);
    videoOut = lib.data.videoOut(outVideoPath);
    plotUtils = lib.utils.imgPlot();
    numFrames = video.frames;
    
    load(tracksProcessedPath,'facedets','trackids','falsepositives');
    frames = [facedets.frame];
    
    for i=11000:12250%numFrames
        fprintf('%d\n',i);
        img = video.getFrame(i);
        idx = find(frames == i);
        if(~isempty(idx))
            for j=1:numel(idx)
                frameData = facedets(idx(j));
                det = frameData.rectSmoothed;
                fp = falsepositives(trackids==frameData.track);
                img = plotUtils.plotDet(img,det,frameData.track,fp);
            end
        end
        videoOut.addFrame(img);
    end
    videoOut.close();
end