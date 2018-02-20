function nRemaining = vcDeleteObject(objType,val)
% Delete the specified object type of at position val
%
%    nRemaining = vcDeleteObject(objType,[val])
%
% The ISET objects that can be deleted by this call are: 
%   SCENE, OPTICALIMAGE (OI), VCIMAGE (IMGPROC), ISA (SENSOR).
%
% If val is not passed in this call is equivalent to vcDeleteSelectedObject
%
% Example:
%   vcDeleteObject('SCENE',1) sceneWindow();
%   vcDeleteObject('SCENE',3); sceneWindow();

% Copyright ImagEval Consultants, LLC, 2005.

% Get the selected object data structure and its position (val) in the list
if ieNotDefined('objType'), error('Object type required'); end
objType = vcEquivalentObjtype(objType);

% Set val to as the selected object
if exist('val','var') && ~isempty(val)
    vcSetSelectedObject(objType,val)
end

% Delete the selected object
nRemaining = vcDeleteSelectedObject(objType);

return;

