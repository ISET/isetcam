function write_video_smooth(framesPath,pattern,tracksPath,videoOutPath)
% write the face tracks into a video
% Qiong, 26/05/2016

    video = lib.data.videoFrames(framesPath,pattern);
    plotUtils = lib.utils.imgPlot();
    load(tracksPath,'facedets');
    
    frames = [facedets.frame];
    uframes = unique(frames,'stable');    

    [m,n,l] = size(video.getFrame(uframes(1)));
    obj = zeros(m,n,l,numel(uframes));
    
    for i=1:numel(uframes)
        fprintf('%d\n',i);
        frame = uframes(i);
        img = video.getFrame(frame);
        
        ind = find(frame == frames);
        for j = 1: numel(ind)
            det = facedets(ind(j)).rectSmoothed;
            img = plotUtils.plotDet(img,det,facedets(ind(j)).track,0);
        end
        obj(:,:,:,i) = img;

    end
    
    % write into video
    v = VideoWriter(videoOutPath);
    open(v)
    writeVideo(v,obj/255);
    close(v)

end