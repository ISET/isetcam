function write_shots_frame(framesPath,pattern,shotsPath,annoOutPath)

    video = lib.data.videoFrames(framesPath,pattern);
    plotUtils = lib.utils.imgPlot();

    load(shotsPath);
    
    for i=1:numel(startFrames)
        fprintf('%d\n',i);
        startframe = startFrames(i);
        endframe = endFrames(i);
        
        shot_imgs = {};
                
        numframe = endframe-startframe+1;
        frame_3 = [startframe, startframe+ ceil(numframe/2),endframe];       
        for j=1: numel(frame_3)
            frame = frame_3(j);
            shot_imgs{j} = video.getFrame(frame);
        end
        shot_imgs = cat(2,shot_imgs{:});
        imshow(shot_imgs);
        close;
        
        imgOutPath = sprintf('%s/%05d.jpg',annoOutPath,i);
        imwrite(shot_imgs,imgOutPath);
    end
end