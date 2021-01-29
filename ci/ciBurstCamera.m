classdef ciBurstCamera < ciCamera
    %CIBURSTCAMERA Sub-class of ciCamera that adds burst and bracketing
    %   Basic multi-capture functionality, to be used for testing
    %   and as a base class for additional enhancements
    
    % History:
    %   Initial Version: D.Cardinal 12/2020

    properties
        numHDRFrames = 3;
        numBurstFrames = 3;
        numFocusFrames = 5; 
    end
    
    methods
        function obj = ciBurstCamera()
            %CIBURSTCAMERA Construct an instance of this class
            obj.cmodules(1) = ciCModule(); % 1 (or more) CModules
            obj.isp = ciBurstIP();     % extended ip
            obj.supportedIntents = {'Auto', 'HDR', 'Burst', 'Focus'};
            
        end
        
       function ourPicture = TakePicture(obj, aCIScene, intent, options, camProps)
           
           arguments
               obj;
               aCIScene;
               intent;
               options.numHDRFrames = 3;
               options.numBurstFrames = 3;
               options.numFocusFrames = 3;
               options.returnIP = obj.isp.returnIP;
               camProps.?ciCamera;
               camProps.imageName char = '';
               camProps.reRender (1,1) {islogical} = true;
           end
           if ~isempty(camProps.imageName)
               obj.isp.ip = ipSet(obj.isp.ip, 'name', camProps.imageName);
           end
           obj.numHDRFrames = options.numHDRFrames;
           obj.numBurstFrames = options.numBurstFrames;
           obj.numFocusFrames = options.numFocusFrames;

           
           varargin=namedargs2cell(camProps); 
           switch intent
               case 'FocusStack'
                   stackFrames = obj.numFocusFrames;
               otherwise
                   stackFrames = 0;
           end
           ourPicture = TakePicture@ciCamera(obj, aCIScene, intent, ...,
               'returnIP', options.returnIP, 'stackFrames', stackFrames, varargin{:});
           
       end
       
       % Decides on number of frames and their exposure times
       % based on the preview image passed in from the camera module
       function [expTimes] = planCaptures(obj, previewImages, intent)

           if isequal(previewImages{1}.type, 'opticalimage')
               oi = previewImages{1};
           else
               oi = oiCompute(previewImages{1},obj.cmodules(1).oi);
           end
           % by default set our base exposure to simple auto-exposure
           baseExposure = [autoExposure(oi, obj.cmodules(1).sensor)];

          
           switch intent
               case 'HDR'
                   % Bracket the requested number of frames around our base
                   % exposure. 
                   % TODO: An AutoHDR based on overall
                   % scene dynamic range.
                   numFrames = obj.numHDRFrames;
                   frameOffset = (numFrames -1) / 2;
                   if numFrames > 1 && ~isodd(numFrames)
                       numFrames = numFrames + 1;
                   end
                   expTimes = repmat(baseExposure, 1, numFrames);
                   expTimes = expTimes.*(2.^[-1*frameOffset:1:frameOffset]);
               case {'Burst', 'FocusStack'}
                   % For now this is a very simple algorithm that just
                   % takes the base exposure and divides it into the number
                   % of frames.
                   switch intent
                       case 'Burst'
                           numFrames = obj.numBurstFrames;
                       case 'FocusStack'
                           numFrames = obj.numFocusFrames;
                   end
                   % Future: Algorithm here to calculate number of images and
                   % exposure time based on estimated processing power,
                   % lighting, and possibly motion/intent
                   expTimes = repmat(baseExposure/numFrames, 1, numFrames);
                                                        
               otherwise
                   % just do what the base camera class would do
                   [expTimes] = planCaptures@ciCamera(obj, previewImages, intent);
           end
       end
              
       function infoArray = showInfo(obj)
           infoArray = showInfo@ciCamera(obj);
           infoArray = [infoArray; {'HDR Frames', obj.numHDRFrames}];
           infoArray = [infoArray; {'Burst Frames', obj.numBurstFrames}];
           infoArray = [infoArray; {'Focus Frames', obj.numFocusFrames}];
       end
    end
end

