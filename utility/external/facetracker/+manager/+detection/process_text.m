function process_text(shotsFile,subtitleFile,tranScriptFile,speakerMappingFile,ecombinedPath)
    
    dataProcessor = lib.alignment.processor.DataProcessor(shotsFile,subtitleFile,tranScriptFile);
    %dataProcessor.getSpeakerMappingFile(speakerMappingFile);
    dataProcessor.makeDataFile(speakerMappingFile,ecombinedPath);

end