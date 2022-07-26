function compute_ub(videoPath,ubPath)

    addpath ~/Work/videolib/ubc_v1/
    addpath ~/Work/dpm_face/voc-release5/
    run ~/Work/dpm_face/voc-release5/startup.m
    
    ubc = load('~/Work/videolib/ubc_v1/models/mmModel_dsc.mat', 'mmModel'); % load UBC model
    % 4-UB configurations yield no benefit, remove them to improve detection speed
    ubc.mmModel.cmModels(4) = [];
    % load DPM model and cascade version to compute dense scores
    dpm = load('~/Work/videolib/ubc_v1/models/ubDet_permuteDsc_nComp-2_nPart-2_cascade.mat', 'cscModel', 'model');
    video = lib.data.video(videoPath);
    numFrames = video.frames;
    ubRects = {};isFromUbc={};cfgBox={};
    ubd = MUB_UbDet();
    parfor i =1:numFrames
        img = video.getFrame(i);
        [ubRects{i}, isFromUbc{i}, cfgBox{i}] = ubd.ubcCascadeDetect(img, dpm.model, dpm.cscModel, ubc.mmModel);                         
            
    end
       
         
            
    save(ubPath,'ubRects','isFromUbc','cfgBox','-v7.3');     
                 
           
            
    
end