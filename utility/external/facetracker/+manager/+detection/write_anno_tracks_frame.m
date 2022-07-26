function write_anno_tracks_frame(framesPath,pattern,tracksPath,annoOutPath,outFile)

    video = lib.data.videoFrames(framesPath,pattern);
    plotUtils = lib.utils.imgPlot();
    fp = fopen(outFile,'w+');
    load(tracksPath,'facedets');
    
    l = 1;
    
    tracks = [facedets.track];
    utracks = unique(tracks);    
    for i=1:numel(utracks)
        fprintf('%d\n',i);
        selIdx  = [];
        idx = find(tracks == utracks(i));
        selIdx(1) = idx(1);
        selIdx(2) = idx(ceil(numel(idx)/3));
        selIdx(3) = idx(end);
        
        if numel(idx) >= 3
            track_imgs = {};
            for j=1:numel(selIdx)
               frame_data = facedets(selIdx(j));
               img = video.getFrame(frame_data.frame);
               det = frame_data.rect;
               det(3) = det(3)-det(1); det(4) = det(4) - det(2);
               track_imgs{j} = plotUtils.plotDet(img,det,l,0);  
            end
            track_imgs = cat(2,track_imgs{:});
            imshow(track_imgs);
            close;
%             imgOutPath = sprintf('%s/%05d.jpg',annoOutPath,utracks(i));
%             imwrite(track_imgs,imgOutPath);
%             fprintf(fp,'%05d unknown\n',utracks(i));
            
            l = l+1;
        end
    end
    fclose(fp);
end