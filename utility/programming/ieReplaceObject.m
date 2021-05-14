function ieReplaceObject(obj,val)
%Replace an object in the vcSESSION variable
%
%    ieReplaceObject(obj,[val])
%
% Replace an existing ISETCam struct, either a SCENE, OPTICALIMAGE, OPTICS,
% SENSOR, PIXEL or IP in the vcSESSION global variable.
%
% obj:  The ISETCam object
% val:  The number of the object to be replaced.  If val is not
%       specified, then the currently selected object is replaced.
%
% When  replacing OPTICS or PIXEL the val refers to the OPTICALIMAGE or
% SENSOR that contain the OPTICS or PIXEL.
%
% The object that is replaced (or its parent) are set to be the selected
% object.
%
% Examples:
%   ieReplaceObject(oi,3);
%   ieReplaceObject(oi);
%   ieReplaceObject(sensor,val);
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
global vcSESSION;

objType = vcGetObjectType(obj);
objType = vcEquivalentObjtype(objType);

%%
if ieNotDefined('val')
    val = vcGetSelectedObject(objType);
    if isempty(val),  val = 1; end
end

% Should be handled by ieSessionSet
switch lower(objType)
    case 'scene'
        vcSESSION.SCENE{val} = obj;
    case 'opticalimage'
        vcSESSION.OPTICALIMAGE{val} = obj;
    case 'optics'
        vcSESSION.OPTICALIMAGE{val}.optics = obj;
    case 'isa'
        vcSESSION.ISA{val} = obj;
    case 'pixel'
        vcSESSION.ISA{val}.pixel = obj;
    case 'vcimage'
        vcSESSION.VCIMAGE{val} = obj;
    case 'display'
        vcSESSION.DISPLAY{val} = obj;
    otherwise
        error('Unknown object type');
end

vcSetSelectedObject(objType,val)

end