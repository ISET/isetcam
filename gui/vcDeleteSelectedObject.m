function nRemaining = vcDeleteSelectedObject(objType)
% Delete the current selected object of some type
%
%     nRemaining = vcDeleteSelectedObject(objType)
%
%  The basic ISET object types deleted by this call are: SCENE,
%  OPTICS, VCIMAGE, ISA.
%
%  The number of remaining objects of that type is returned. 
%
% Example:
%   vcDeleteSelectedObject('SCENE')
%
% Copyright ImagEval Consultants, LLC, 2005.

% Get the selected object data structure and its position (val) in the list
objType = vcEquivalentObjtype(objType);
val = vcGetSelectedObject(objType);

if isempty(val)
    warning('No object to delete')
    return;
end

obj = vcGetObjects(objType);
nObj = length(obj);
if nObj == 1
    newObj{1} = [];
    val = [];
else
    % Copy all but the selected object
    jj = 0;
    for ii=1:nObj
        if (ii ~= val)
            jj = jj + 1;
            newObj{jj} = obj{ii};
        end
    end
    val = max(1,val-1);
end

% Reset the new list of objects
vcSetObjects(objType,newObj);

% Pick a new selected object
vcSetSelectedObject(objType,val);

nRemaining = length(newObj);
% fprintf('%.0f remaining objects\n',nRemaining);

return;

