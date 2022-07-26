function compute_features(videoPath,tracksPath,featsFile)

    descDim = 64;
    vocSize = 512;
    cbookDir = '/users/omkar/Work/videolib/data/';
    
    
    facedesc = lib.facedesc.poolFVTrackJitt();
    % PCA & GMM paths
    dimredPath = sprintf('%s/PCA_%d.mat', cbookDir, descDim);
    gmmPath = sprintf('%s/gmm_%d.mat', cbookDir, vocSize);
    % load and set feat projection
    linTrans = load(dimredPath);
    facedesc.set_feat_proj(linTrans);
    % load and set codebook
    load(gmmPath, 'codebook');
    facedesc.set_codebook(codebook);

    video = lib.data.video(videoPath);
    facedets = [];
    load(tracksPath,'facedets');
    
    tracks = [facedets.track];
    utracks = unique(tracks);
    
    feats = -ones(facedesc.get_dim(),numel(utracks));
    parfor i=1:numel(utracks)
        try    
            idx = find(tracks == utracks(i));
            track_data = facedets(idx);
            %feats = facedesc.compute(video,track_data);
            feats(:,i) = facedesc.compute(video,track_data);
        catch
            continue;
        end
       
    end
    save(featsFile,'feats','-v7.3');
end