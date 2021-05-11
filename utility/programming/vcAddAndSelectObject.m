function val = vcAddAndSelectObject(objType, obj)
%Add and select an object to the vcSESSION data
%
%    val = vcAddAndSelectObject(obj)          (preferred)
%    val = vcAddAndSelectObject(objType,obj)  (supported)
%
% The object is added to the vcSESSION global variable. The object type
% can be one of the ISET object types, SCENE, VCIMAGE,  OPTICALIMAGE
% ISA/SENSOR or their equivalents.
%
% The new object value is assigned the next new value.
% To see the object in the appropriate window, you can call the window
% itself.
%
% Example:
%  scene = sceneCreate;
%  newObjVal = vcAddAndSelectObject(scene);
%  sceneWindow;
%
% Older syntax is supported, but not preferred
%  newObjVal = vcAddAndSelectObject('OPTICALIMAGE',oi);
%  vcAddAndSelectObject('SCENE',scene);
%
%
% Copyright ImagEval Consultants, LLC, 2005.

% Programming Notes:
% start using ieSessionSet instead of the direct assignments here

global vcSESSION;

% This way, the call can be
% vcAddAndSelectObject(scene) instead of
% vcAddAndSelectObject('scene',scene), which was the original
%
if checkfields(objType, 'type'), obj = objType;
    objType = objType.type;
end

% Makes objType proper type and forces upper case.
objType = vcEquivalentObjtype(objType);
val = vcNewObjectValue(objType);

% Assign object, passed in as 3rd variable, to the vcSESSION global.
% Should be ieSessionSet, not this.
if exist('obj', 'var')
    switch upper(objType)
        case {'SCENE'}
            vcSESSION.SCENE{val} = obj;
        case {'OPTICALIMAGE'}
            vcSESSION.OPTICALIMAGE{val} = obj;
        case {'ISA'}
            vcSESSION.ISA{val} = obj;
        case {'VCIMAGE'}
            vcSESSION.VCIMAGE{val} = obj;
        case {'DISPLAY'}
            vcSESSION.DISPLAY{val} = obj;
        otherwise
            error('Unknown object type');
    end
end

vcSetSelectedObject(objType, val);


return;
