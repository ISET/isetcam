classdef cpIP < handle
    %cpIP Wrapper for ip to support computational cameras
    %   TBD how much we need to extend the current ip
    %   versus adding functionality to it or using the ciCamera class, but
    %   having this class at least gives us options
    %
    % History:
    %   Initial Version: D. Cardinal, 12/2020
    
    properties
        defaultDisplay = 'OLED-Sony.mat'; % in case this makes a difference
        ip = [];
    end
    
    methods
        function obj = cpIP(userIP)
            %cpIP Construct an instance of this class
            %   create a programmable ip
            %   for now, just a straight wrapper on an ip
            if exist('userIp') && ~isempty(userIP)
                obj.ip = userIP;
            else
                obj.ip = ipCreate('ci IP', [], obj.defaultDisplay); % by default we just wrap an ip
                
            end
        end
        
        function aPicture = compute(obj, sensorImages)
            %Compute final image from sensor captures
            aPicture = ipCompute(obj.ip, sensorImages);
        end
        
        % Here we compute the image (in the form of an ip) that we get from
        % photographing our scene. NOTE: The default ciCamera does not do
        % any advanced processing, so it always returns an ip, not an RGB
        % result that has been further processed.
        function ourPhoto = ispCompute(obj, sensorImages, intent)
            switch intent
                case 'HDR'
                    % ipCompute for HDR assumes we have an array of voltages
                    % in a single sensor, NOT an array of sensors
                    % so first we merge our sensor array into one sensor
                    % For now this is simply concatenating, but could be
                    % more complex in a sub-class that wanted to be more
                    % clever
                    sensorImage = obj.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'bracketing');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'longest');
                    
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    ourPhoto = obj.ip;
                case 'Burst'
                    % baseline is just sum the voltages, without alignment
                    sensorImage = obj.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    ourPhoto = obj.ip;
                case 'FocusStack'
                    % Doesn't stack yet. Needs to do that during merge!
                    sensorImage = obj.isp.mergeSensors(sensorImages);
                    sensorImage = sensorSet(sensorImage,'exposure method', 'burst');
                    
                    %obj.ip = ipSet(obj.ip, 'render demosaic only', 'true');
                    obj.ip = ipSet(obj.ip, 'combination method', 'sum');
                    
                    % old ipBurstMotion  = ipCompute(ipBurstMotion,sensorBurstMotion);
                    obj.ip = ipCompute(obj.ip, sensorImage);
                    ourPhoto = obj.ip;
                    
                otherwise
                    % This lower-leval routine is called once we have our sensor
                    % image(s), and generates a final image based on the intent
                    % Except this doesn't seem to deal with multiple
                    % images?
                    for ii=1:numel(sensorImages)
                        sensorWindow(sensorImages(ii));
                        ourPhoto = ipCompute(obj.ip, sensorImages(ii));
                    end
            end
            
            
        end
        % take a sequence of frames that are in separate sensor objects
        % and combine them into a single struct for processing by ip.
        % Right now this is simple processing of voltages. Should also
        % look at demosaic first and other options
        function singleSensor = mergeSensors(obj, sensorArray)
            singleSensor = sensorArray(1);
            for ii = 2:numel(sensorArray)
                singleSensor = sensorSet(singleSensor, 'exposure time', ...
                    [sensorGet(singleSensor,'exposure time') sensorGet(sensorArray(ii), 'exposure time')]);
                singleSensor.data.volts(:,:,ii) = sensorArray(ii).data.volts;
            end
        end
    end
end

