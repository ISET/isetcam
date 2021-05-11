function nRemaining = vcDeleteSelectedObject(objType)
% Delete the current selected object of some type
%
%     nRemaining = vcDeleteSelectedObject(objType)
%
%  The ISET object types deleted by this call are:
%    SCENE, OPTICS, VCIMAGE, ISA.
%
%  The number of remaining objects in the vcSESSION slot of that type is
%  returned.
%
% Example:
%   vcDeleteSelectedObject(scene);    % Where scene is a struct
%   vcDeleteSelectedObject('SCENE')   % Where a string
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Deal with the struct call
if isstruct(objType), objType = objType.type; end

% Get the selected object data structure and its position (val) in the list
objType = vcEquivalentObjtype(objType);
val = vcGetSelectedObject(objType);

if isempty(val)
    warning('No object of type %s to delete', objType)
    return;
end

%%
obj = vcGetObjects(objType);
nObj = length(obj);
if nObj == 1
    obj(1) = [];
    val = [];
else
    % Note the parenthesis, not {}
    obj(val) = [];
    val = max(1, val-1);
end

% Reset the new list of objects
vcSetObjects(objType, obj);

% Pick a new selected object
vcSetSelectedObject(objType, val);

nRemaining = length(obj);
% fprintf('%.0f remaining objects\n',nRemaining);

end
