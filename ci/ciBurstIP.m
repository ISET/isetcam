classdef ciBurstIP < ciIP
    %CIBURSTIP Burst-supporting version of ciIP Wrapper for ip to support computational cameras
    %
    % History:
    %   Initial Version: D. Cardinal, 01/2021
    
    properties
        % sub-class properties here
    end
    
    methods
        function obj = ciBurstIP(userIP)
            %CIBURSTIP Construct an instance of this class
            %   create a programmable ip
            if ~exist('userIP', 'var'); userIP = []; end
            obj = obj@ciIP(userIP);
        end
        
        function aPicture = compute(sensorImages)
            %Compute final image from sensor captures
            aPicture = compute@ciIP(sensorImages);
        end
        
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

