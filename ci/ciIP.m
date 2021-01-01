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
    end
end

