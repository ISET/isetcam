function label_preprocess(videoPath,tracksPath,annoFile,featsFile)



    lblUtils = lib.labelling.utils();
    video = lib.data.video(videoPath);
    
    [gtTracks labels] = textread(annoFile,'%s %s');
    gtTracks = lblUtils.convertGTTracks(gtTracks);
    [gt,labelMap] = lblUtils.labelsToGT(labels,[]);
    
    facedets = [];
    load(tracksPath,'facedets');

    feats = [];
    load(featsFile);
    
    [facedets,feats,gt,trackIds,labels] = lblUtils.removeItemsFor(labelMap,gt,...
        {'FalsePositive','Ignore'},gtTracks,facedets,feats,labels);
    
    
    

    if(1)
    load('data/g0.25_gb1.mat');
    tfeats = model.state.W*feats;
    K = lblUtils.computeSimilarity(tfeats);
    else
        K = [];
        load ~/scratch/test_kernel.mat;
    end
    
    [scores,trackpairs,pair_gt,sameshot] = lblUtils.makepairs(K,facedets,gt);
    [facedets] = lblUtils.mergeInShot(facedets,scores,trackpairs,sameshot);
    [feats,gt,trackIds,labels] = lblUtils.reorganise(facedets,feats,gt,trackIds,labels);
    track_shots = lblUtils.getTrackShots(facedets);
    
    
    tOvl = lblUtils.getTemporalOverlap(facedets,trackIds,track_shots);
    tfeats = model.state.W*feats;
    K = lblUtils.computeSimilarity(tfeats);
    K = K + 10000*tOvl;
    [scores,trackpairs,pair_gt,sameshot] = lblUtils.makepairs(K,facedets,gt);
    [r p  info ] = vl_pr(pair_gt,-scores);
    [facedets] = lblUtils.mergeInShot(facedets,scores,trackpairs,ones(size(pair_gt)));
    
end