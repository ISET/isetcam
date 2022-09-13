function write_frames_tracks(framesPath,pattern,tracksPath,showtracksPath)
% write the frames with detection contained in tracks
% Qiong, 26/05/2016

    video = lib.data.videoFrames(framesPath,pattern);
    plotUtils = lib.utils.imgPlot();
    load(tracksPath,'facedets');
    
    frames = [facedets.frame];
    uframes = unique(frames,'stable');
    
    for i=1:numel(uframes)
        fprintf('%d\n',i);
        frame = uframes(i);
        img = video.getFrame(frame);
        
        ind = find(frame == frames);
        if ~isempty(ind)
            for j = 1: numel(ind)
                det = facedets(ind(j)).rect;
                det(3) = det(3)-det(1); det(4) = det(4) - det(2);
                img = plotUtils.plotDet(img,det,facedets(ind(j)).track,0);
            end
        end 
%         imshow(img);
%         close;
        
        imgOutPath = sprintf('%s/%05d.jpg',showtracksPath,frame);
        imwrite(img,imgOutPath);
    end
end