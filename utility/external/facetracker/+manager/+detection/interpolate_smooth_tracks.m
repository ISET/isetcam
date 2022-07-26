function interpolate_smooth_tracks(tracksPath)

    load(tracksPath,'facedets');
    trackprocessor = lib.tracking.postProcessor();
    facedets = trackprocessor.process(facedets);

    save(tracksPath,'facedets','-append');
     
    
   
end