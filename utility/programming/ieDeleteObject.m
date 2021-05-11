function nRemaining = ieDeleteObject(objType, val)
% Delete the specified object type of at position val
%
%    nRemaining = ieDeleteObject(objType,[val])
%
% The ISET objects that can be deleted by this call are:
%   SCENE, OPTICALIMAGE (OI), VCIMAGE (IMGPROC), ISA (SENSOR).
%
% Input:
%   objType:  A string or an object struct with objType.type defined
%   val:      Integer defining which object in the database list to
%             delete. If val is not passed in this call is equivalent
%             to vcDeleteSelectedObject
% Outputs:
%    nRemaining: How many objects of that type remain in the database
%
% Examples:
%   scene = sceneCreate; ieAddObject(scene); sceneWindow;
%   ieDeleteObject(scene); sceneWindow;
%   ieAddObject(scene); sceneWindow;
%   ieDeleteObject('SCENE',1); sceneWindow;
%   ieAddObject(scene); ieAddObject(scene); sceneWindow;
%   ieDeleteObject('SCENE',2); sceneWindow;
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Get the selected object data structure and its position (val) in the list
if ieNotDefined('objType'), error('Object type required'); end

if isstruct(objType), objType = objType.type; end

objType = vcEquivalentObjtype(objType);

if ieNotDefined('val')
    val = vcGetSelectedObject(objType);
end

% Set val to the selected object
if exist('val', 'var') && ~isempty(val)
    vcSetSelectedObject(objType, val)
end

% Delete the selected object
nRemaining = vcDeleteSelectedObject(objType);

end
