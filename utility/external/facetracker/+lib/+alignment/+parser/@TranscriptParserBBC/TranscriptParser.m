classdef TranscriptParser < handle



    methods

        function obj = TranscriptParser()
        end
        
        transcript = parseTranscript(obj,subTitleFile)
        
        data = parseChunk(obj,chunk)
        
    end

end
