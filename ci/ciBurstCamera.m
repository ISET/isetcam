classdef ciBurstCamera < ciCamera
    %CIBURSTCAMERA Sub-class of ciCamera that adds burst and bracketing
    %   Basic multi-capture functionality, to be used for testing
    %   and as a base class for additional enhancements
    
    % History:
    %   Initial Version: D.Cardinal 12/2020

    properties
        
    end
    
    methods
        function obj = ciBurstCamera(varargin)
            %CIBURSTCAMERA Construct an instance of this class
            %   First invoke our parent ciCamera class
            obj = obj@ciCamera(varargin);

        end
        
       function ourPicture = TakePicture(obj, scene, intent)

            ourPicture = TakePicture@ciCamera(obj, scene, intent);
            % Typically we'd invoke the parent before or after us
            % or to handle cases we don't need to
            % Let's think about the best way to do that.
            % Otherwise could be some other type of specialized call?
            
       end
       
       % Decides on number of frames and their exposure times
       % based on the preview image passed in from the camera module
       function [expTimes] = planCaptures(obj, previewImage, intent)
           switch intent
               case 'HDR'
                   expTimes = [.05 .1 .2]; % for now
               case 'Burst'
                   expTimes = [.05 .05 .05]; % for now
               otherwise
                   [expTimes] = planCaptures@ciCamera(obj, previewImage, intent);
           end
       end
    end
end

