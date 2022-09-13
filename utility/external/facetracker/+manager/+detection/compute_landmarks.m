function compute_landmarks(videoPath,tracksPath)

    video = lib.data.video(videoPath);
    %video.gatherinfo();
    facedets =[];
    load(tracksPath,'facedets');
    
    numDets = numel(facedets);
    
    lmdet = lib.landmarks.gdrLandmarkDet('~/Work/videolib/data/pre_trained_models/dpm_model.mat',...
    '~/Work/videolib/data/pre_trained_models/Profile_model.mat');

    for i =1:numDets
      %try 
        img = video.getFrame(facedets(i).frame);
       	facedets(i).pts = lmdet.detect(img,facedets(i).rect,facedets(i).pose);
      %catch
      %  continue;
      %end
    end

    save(outPath,'facedets','-append');
end