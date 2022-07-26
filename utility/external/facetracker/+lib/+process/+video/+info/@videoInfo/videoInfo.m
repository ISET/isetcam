classdef videoInfo < handle

    properties
    end

    methods

        function obj = video()

        end

        faceImg = extract_face(obj, img, detPts, alignMethod)
        tform = computeTform(obj,detPts,type)

    end

end
~        
