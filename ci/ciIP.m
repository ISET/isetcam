classdef ciIP
    %CIIP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ip = ipCreate();
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

