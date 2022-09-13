classdef SubtitleParser < handle

    properties
        frameRate
    end

    methods

        function obj = SubtitleParser(frameRate)
            obj.frameRate = frameRate;
        end
        
        subtitles = parseSubTitles(obj,subTitleFile)
            
        frame = subtitleTimeToFrame(obj,timeStr)
        
    end

end
