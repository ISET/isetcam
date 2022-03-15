classdef cpBurstCamera < cpCamera
    %CIBURSTCAMERA Sub-class of cpCamera that adds burst and bracketing
    %   Basic multi-capture functionality, to be used for testing
    %   and as a base class for additional enhancements
    %
    % Properties
    %  numHDRFrames
    %  numBurstFrames
    %  numFocusFrames
    %  numVideoFrames
    %
    % Supports Intents:
    %  'Auto', 'HDR', 'Burst', 'Focus', 'Video'
    %
    % Methods:
    %  planCaptures
    %  TakePicture
    %  showInfo
    %
    % History:
    %   Initial Version: D.Cardinal 12/2020
    
    properties
        numHDRFrames = 3;
        numBurstFrames = 3;
        numFocusFrames = 5;
        numVideoFrames = 60;
    end
    
    methods
        function obj = cpBurstCamera()
            %CPBURSTCAMERA Construct an instance of this class
            obj.cmodules(1) = cpCModule(); % 1 (or more) CModules
            obj.isp = cpBurstIP();     % extended ip
            obj.supportedIntents = {'Auto', 'HDR', 'Burst', 'Focus', 'Video'};
            
        end
        
        function ourPicture = TakePicture(obj, aCPScene, intent, options, camProps)
            
            arguments
                obj;
                aCPScene;
                intent;
                options.numHDRFrames = 3;
                options.numBurstFrames = 3;
                options.numFocusFrames = 3;
                options.numVideoFrames = 60;
                options.insensorIP = obj.isp.insensorIP;
                options.focusMode char = 'Auto';
                options.focusParam = 'Center'; % for Manual is distance in m
                camProps.?cpCamera;
                camProps.imageName char = '';
                camProps.reRender (1,1) {islogical} = true;
            end
            if ~isempty(camProps.imageName)
                obj.isp.ip = ipSet(obj.isp.ip, 'name', camProps.imageName);
            else
                obj.isp.ip = ipSet(obj.isp.ip, 'name', 'Burst Camera Image');
            end
            obj.numHDRFrames = options.numHDRFrames;
            obj.numBurstFrames = options.numBurstFrames;
            obj.numVideoFrames = options.numVideoFrames;
            
            varargin=namedargs2cell(camProps);
            switch options.focusMode
                case 'Stack'
                    obj.numFocusFrames = options.focusParam;
                otherwise
                    obj.numFocusFrames = 0;
            end
            
            ourPicture = TakePicture@cpCamera(obj, aCPScene, intent, ...,
                'insensorIP', options.insensorIP, 'focusParam', options.focusParam, 'focusMode', options.focusMode, varargin{:});
            
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
            baseExposure = [autoExposure(oi, obj.cmodules(1).sensor, .95, 'default')];
            
            
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
                case {'Burst', 'FocusStack', 'Focus'}
                    % For now this is a very simple algorithm that just
                    % takes the base exposure and divides it into the number
                    % of frames.
                    switch intent
                        case 'Burst'
                            numFrames = obj.numBurstFrames;
                        case {'FocusStack', 'Focus'}
                            numFrames = obj.numFocusFrames;
                    end
                    % Future: Algorithm here to calculate number of images and
                    % exposure time based on estimated processing power,
                    % lighting, and possibly motion/intent
                    expTimes = repmat(baseExposure/numFrames, 1, numFrames);   
                case {'Video'}
                    numFrames = obj.numVideoFrames;
                    expTimes = repmat(baseExposure, 1, numFrames);
                otherwise
                    % just do what the base camera class would do
                    [expTimes] = planCaptures@cpCamera(obj, previewImages, intent);
            end
        end
        
        function infoArray = showInfo(obj)
            infoArray = showInfo@cpCamera(obj);
            infoArray = [infoArray; {'HDR Frames', obj.numHDRFrames}];
            infoArray = [infoArray; {'Burst Frames', obj.numBurstFrames}];
            infoArray = [infoArray; {'Focus Frames', obj.numFocusFrames}];
        end
    end
end

