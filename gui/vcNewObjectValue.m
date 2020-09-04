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
        
        if isfield(vcSESSION,'OPTICALIMAGE')
            val(1) = length(vcSESSION.OPTICALIMAGE) + 1;
        else
            val(1) = 1; % don't know if this works, but certainly can't use length!
        end
        if isfield(vcSESSION,'ISA')
            val(2) = length(vcSESSION.ISA) + 1;
        else
            val(2) = 1; % don't know if this works, but certainly can't use length!
        end
        if isfield(vcSESSION,'VCIMAGE')
            val(3) = length(vcSESSION.VCIMAGE) + 1;
        else
            val(3) = 1; % don't know if this works, but certainly can't use length!
        end
        
    otherwise
        % Returns one value for this object
        object = vcGetObjects(objType);
        if isempty(object{1}),  val = 1;
        else,                   val = length(object) + 1;
        end
end

end

