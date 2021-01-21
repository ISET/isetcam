classdef ciBurstCamera < ciCamera
    %CIBURSTCAMERA Sub-class of ciCamera that adds burst and bracketing
    %   Basic multi-capture functionality, to be used for testing
    %   and as a base class for additional enhancements
    
    % History:
    %   Initial Version: D.Cardinal 12/2020

    properties
        numHDRFrames;
        numBurstFrames;
        numFocusFrames; 
    end
    
    methods
        function obj = ciBurstCamera()
            %CIBURSTCAMERA Construct an instance of this class
            %   First invoke our parent ciCamera class
            obj = obj@ciCamera();

        end
        
       function ourPicture = TakePicture(obj, aCIScene, intent, options, camProps)
           
           arguments
               obj;
               aCIScene;
               intent;
               options.numHDRFrames = 3;
               options.numBurstFrames = 3;
               options.numFocusFrames = 5;
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
           ourPicture = TakePicture@ciCamera(obj, aCIScene, intent, varargin{:});
           
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
               case 'Burst'
                   % For now this is a very simple algorithm that just
                   % takes the base exposure and divides it into the number
                   % of frames.
                   numFrames = obj.numBurstFrames;
                   frameOffset = (numFrames -1) / 2;
                   if numFrames > 1 && ~isodd(numFrames)
                       numFrames = numFrames + 1;
                   end
                   % Future: Algorithm here to calculate number of images and
                   % exposure time based on estimated processing power,
                   % lighting, and possibly motion/intent
                   expTimes = repmat(baseExposure/numFrames, 1, numFrames);
                   
               case 'FocusStack'
                   % we know the photographer wants to focus stack. Do we
                   % want them to specify the parameters, or should we try
                   % to figure them out? For a 3D scene we could
                   % automatically figure out the scene depth and iterate
                   % through it.
                   
                   % In the case of pbrt+lens file, we render a series of
                   % OIs in pbrt (NOT IMPLEMENTED). For now, we're working
                   % on the case where we get a 3D scene from pbrt or ISET
                   % and using a synthetic defocus. This is NOT as
                   % accurate, but a starting point.:)
                   error("Focus Stacking not supported yet.");
                  
               otherwise
                   % just do what the base camera class would do
                   [expTimes] = planCaptures@ciCamera(obj, previewImages, intent);
           end
       end
       
       % Here we over-ride default processing to compute a photo after we've
       % captured one or more frames. This allows burst & hdr, for example:
       function ourPhoto = computePhoto(obj, sensorImages, intent)

           switch intent
               case 'HDR'
                   % ipCompute for HDR assumes we have an array of voltages
                   % in a single sensor, NOT an array of sensors
                   % so first we merge our sensor array into one sensor
                   % For now this is simply concatenating, but could be
                   % more complex in a sub-class that wanted to be more
                   % clever
                   sensorImage = obj.isp.mergeSensors(sensorImages);
                   sensorImage = sensorSet(sensorImage,'exposure method', 'bracketing');
 
                   ipHDR = ipSet(obj.isp.ip, 'render demosaic only', 'true');
                   ipHDR = ipSet(ipHDR, 'combination method', 'longest');
                   
                   ipHDR = ipCompute(ipHDR, sensorImage);
                   ourPhoto = ipHDR;
               case 'Burst'
                   % baseline is just sum the voltages, without alignment
                   sensorImage = obj.isp.mergeSensors(sensorImages);
                   sensorImage = sensorSet(sensorImage,'exposure method', 'burst');

                   ipBurst = ipSet(obj.isp.ip, 'render demosaic only', 'true');
                   ipBurst = ipSet(ipBurst, 'combination method', 'sum');
                   
                   % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                   ipBurst = ipCompute(ipBurst, sensorImage);
                   ourPhoto = ipBurst;
               otherwise
                   ourPhoto = computePhoto@ciCamera(obj, sensorImages, intent);
           end
           
       end
    end
end

