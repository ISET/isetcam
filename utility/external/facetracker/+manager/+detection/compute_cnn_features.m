function compute_cnn_features(framesPath,pattern,tracksPath,featsFile)

  
    
    facedesc = lib.facedesc.ConvNet();
    video = lib.data.videoFrames(framesPath,pattern);
    facedets = [];
    load(tracksPath,'facedets');
    
    tracks = [facedets.track];
    utracks = unique(tracks);
    
    feats = -ones(facedesc.get_dim(),numel(utracks));
    for i=1:numel(utracks)
        %try    
            idx = find(tracks == utracks(i));
            track_data = facedets(idx);
            %feats = facedesc.compute(video,track_data);
            feats(:,i) = facedesc.compute(video,track_data);
        %catch
        %    continue;
        %end
       
    end
    save(featsFile,'feats','-v7.3');
end