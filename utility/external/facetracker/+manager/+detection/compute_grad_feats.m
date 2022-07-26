function compute_grad_feats(framesPath,pattern,tracksPath,featsPath)

    video = lib.data.videoFrames(framesPath,pattern);
    %video.gatherinfo();
    numFrames = video.frames;
   
    facedets = [];trackids=[];falsepositives=[];
    load(tracksPath);
    
    addpath('/users/omkar/projects/faces/trunk_exp/matlab/');
    addpath(genpath('/users/omkar/third_party/faces/lib_matlab/'));
    addpath(genpath('/users/omkar/third_party/vgg_matlab/'));
    vgg_startup;
    
    addpath('/users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/descriptor')
    addpath('/users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/facedet')
    addpath('/users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/facefeats')
    addpath('/users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/utils')
    addpath('/users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/utils/amfg07-demo-v1/');
    conf.opts.Pmu=[25.0347   34.1802   44.1943   53.4623   34.1208   39.3564   44.9156   31.1454   47.8747 ;
        34.1580   34.1659   34.0936   33.8063   45.4179   47.0043 ...
        45.3628   53.0275   52.7999];
    conf.opts.Pmu(3,:)=1;
    conf.opts.VP=[1 0 ; 2 0 ; 3 0 ; 4 0 ; 5 0 ; 6 0 ; 7 0 ; 8 0 ; 9 0 ; 1 2 ; 3 4 ; 2 3 ; 8 9]';
    conf.opts.scl=1;
    conf.opts.r=7;
    conf.face = load('users/omkar/third_party/faces/sid_desc_branch/branch/CLASS_facepipe/facefeats/model.mat');
    
    


    tracks = [facedets.track];
    featconf = [facedets.featconf];
    feats = {};
    usetracks = [];
    for i=1:numel(trackids)
        
        idx = find(tracks == trackids(i));
        fc = featconf(idx);
        
        if(sum(fc>-15)<5)
            continue;
        else
            usetracks(end+1) = trackids(i);
            fidx = find(fc==max(fc));
            fidx = fidx(1);
            img = video.getFrame(facedets(idx(fidx)).frame);
            feats{end+1} = extdescdxdy(conf.opts,img,facedets(idx(fidx)).P,false);
        end
      
        
    end
    feats = cat(2,feats{:});
    save(featsPath,'feats','usetracks','trackids');
    fprintf('Done\n');
end