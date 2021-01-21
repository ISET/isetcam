classdef ciIP < handle
    %CIIP Wrapper for ip to support computational cameras
    %   TBD how much we need to extend the current ip
    %   versus adding functionality to it, but
    %   having this class at least gives us options
    %
    % History:
    %   Initial Version: D. Cardinal, 12/2020
    
    properties
        defaultDisplay = 'OLED-Sony.mat'; % in case this makes a difference
        ip = [];
    end
    
    methods
        function obj = ciIP(userIp)
            %CIIP Construct an instance of this class
            %   create a programmable ip
            %   for now, just a straight wrapper on an ip
            if exist('userIp')
                obj.ip = userIp;
            else
                obj.ip = ipCreate('ci IP', [], obj.defaultDisplay); % by default we just wrap an ip
                
            end
        end
        
        function aPicture = compute(obj, sensorImages)
            %Compute final image from sensor captures
            aPicture = ipCompute(obj.ip, sensorImages);
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

