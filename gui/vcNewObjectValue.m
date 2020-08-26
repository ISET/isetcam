function val = vcNewObjectValue(objType)
% Return an integer for a new ISET object
%
%   val = vcNewObjectValue(objType)
%
% For scene, oi, sensor, ip and display the return is an integer that is
% just one more than the number of objects currently existing of that type.
%
% For camera the return is a 3-vector with the val for oi, sensor and ip.
%
% For example:
%   nextFreeValue = vcNewObjectValue('scene');
%   ThreeValues   = vcNewObjectValue('camera');
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

switch(objType)
    case 'camera'
        % Return vals for oi, sensor, and ip
        val = zeros(3,1);
        
        val(1) = length(vcSESSION.OPTICALIMAGE) + 1;
        val(2) = length(vcSESSION.ISA) + 1;
        val(3) = length(vcSESSION.VCIMAGE) + 1;
        
    otherwise
        % Returns one value for this object
        object = vcGetObjects(objType);
        if isempty(object{1}),  val = 1;
        else,                   val = length(object) + 1;
        end
end

end

