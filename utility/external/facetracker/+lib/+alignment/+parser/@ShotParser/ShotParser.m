classdef ShotParser < handle

    properties
        frameRate
    end

    methods

        function obj = ShotParser()
        end
        
        shots = parseShots(obj,shotFile)
        
    end

end
