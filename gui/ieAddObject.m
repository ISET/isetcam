function val = ieAddObject(obj)
%Add and select an object to the vcSESSION data
%
%    val = ieAddObject(obj)
%
% The object is added to the vcSESSION global variable. The object type
% can be one of the ISET object types,
%
%   SCENE, OPTICALIMAGE, OPTICS, ISA/SENSOR, PIXEL, IP/VCI
%
% or their aliased names in vcEquivalentObjtype
%
% The new object value is assigned the next available (new) value.
% To see the object in the appropriate window, you call the window
% itself.
%
% Example:
%  scene = sceneCreate;
%  newObjVal = ieAddObject(scene);
%  sceneWindow;
%
% See also:  vcAddAndSelectObject.m
%
% Copyright ImagEval Consultants, LLC, 2013

%%
global vcSESSION;

% Get a value
% Makes objType proper type and forces upper case.
if exist('obj','var'), objType = lower(obj.type);
else,                  error('No object type');
end

% If camera, three values.  Otherwise just one.
val = vcNewObjectValue(objType);

%% Assign object to the vcSESSION global.

% Should be ieSessionSet, not this.
if isequal(objType,'camera')
    % Place the the three camera objects in the database.
    vcSESSION.OPTICALIMAGE{val(1)} = obj.oi;
    vcSESSION.ISA{val(2)} = obj.sensor;
    vcSESSION.VCIMAGE{val(3)} = obj.vci;
    
    vcSetSelectedObject('oi',val(1));
    vcSetSelectedObject('sensor',val(2));
    vcSetSelectedObject('ip',val(3));
else
    switch lower(objType)
        case {'scene'}
            vcSESSION.SCENE{val} = obj;
        case {'opticalimage'}
            vcSESSION.OPTICALIMAGE{val} = obj;
        case {'optics'}
            oi = vcSESSION.OPTICALIMAGE{val};
            oi = oiSet(oi,'optics',obj);
            vcSESSION.OPTICALIMAGE{val} = oi;
        case {'sensor'}
            vcSESSION.ISA{val} = obj;
        case {'pixel'}
            sensor = vcSESSION.ISA{val};
            sensor = sensorSet(sensor,'pixel',obj);
            vcSESSION.ISA{val} = sensor;
        case {'vcimage'}
            vcSESSION.VCIMAGE{val} = obj;
        case {'display'}
            vcSESSION.DISPLAY{val} = obj;
        otherwise
            error('Unknown object type');
    end
    vcSetSelectedObject(objType,val);
end

end
