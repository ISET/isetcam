%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef postProcessor < handle
    
    
    properties
    end

    methods

      function obj = postProcessor()
      end
      
      function facedets = process(obj,facedets)
          tracks  = [facedets.track];
          utracks = unique(tracks);
          
          tracklets = {};
          for i=1:numel(utracks)
              idx = tracks == utracks(i);
              tracklet = facedets(idx);
              tracklet = obj.interpolateTrack(tracklet);
              tracklet = obj.smoothTrack(tracklet);
              tracklets{i} = tracklet;
          end
          facedets = cat(2,tracklets{:});
      end
      
      tracklet = smoothTrack(obj,tracklet);
      faceRectsSmoothed = smoothRects(obj,faceRects);
      
      function [utracks, falsepositives] = getFalsePositiveTracks(obj,facedets)
            tracks = [facedets.track];
            utracks = unique(tracks);
            %falsepositives = zeros(1,numel(utracks));
            tracklen = [];
            for i=1:numel(utracks)
                tracklen(i) = sum(tracks == utracks(i));
            end
            falsepositives = tracklen<10;
     
      end
    end
      
end
