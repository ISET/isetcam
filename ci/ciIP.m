classdef ciIP
    %CIIP Wrapper for ip to support computational cameras
    %   TBD how much we need to extend the current ip
    %   versus adding functionality to it, but
    %   having this class at least gives us options
    %
    % History:
    %   Initial Version: D. Cardinal, 12/2020
    
    properties
        ip = ipCreate(); % by default we just wrap an ip
    end
    
    methods
        function obj = ciIP(userIp)
            %CIIP Construct an instance of this class
            %   create a programmable ip
            %   for now, just a straight wrapper on an ip
            if exist('userIp')
                obj.ip = userIp;
            end
        end
        
        % somewhere we have to extend functionality to handle multiple
        % images, either in ciCamera or here!!
        function aPicture = compute(obj, sensorImages)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            aPicture = ipCompute(obj.ip, sensorImages);
        end
        
        % take a sequence of frames that are in separate sensor objects
        % and combine them into a single struct for processing by ip.
        function singleSensor = mergeSensors(obj, sensorArray)
            singleSensor = sensorArray(1);
            for ii = 2:numel(sensorArray)
                singleSensor = sensorSet(singleSensor, 'exposure time', ...
                    [sensorGet(singleSensor,'exposure time') sensorGet(sensorArray(ii), 'exposure time')]);
                %sensorSet(singleSensor, 'data', ...
                %    [sensorGet(singleSensor,'data') sensorGet(sensorArray(ii), 'data')]);
                % this might be cheating, but can we just append the data
                % arrays? should probably use some version of get & set
                % assume we have volts (ugh:))
                singleSensor.data.volts(:,:,ii) = sensorArray(ii).data.volts;
            end
        end
    end
end

