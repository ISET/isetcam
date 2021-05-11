function newName = vcNewObjectName(objType)
% Create a new name that for this object type
%
%   newName = vcNewObjectName(objType)
%
%   The new name is the same as the object type plus a number of how many
%   objects of this type exist already.
%
% Example:
%    nm = vcNewObjectName('SCENE');
%    nm = vcNewObjectName('VCIMAGE');
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:  The naming convention here permits two objects with the same name
% after objects are deleted.  So we probably need a smarter naming
% convention, say by checking to make sure that the new is not already in
% the name list.

% Get the cell array of current objects of this type
obj = vcGetObjects(objType);
nObj = length(obj);

% If there is only one null object, then this is the first object.
% Otherwise, this name is one more than the current list of objects.
if nObj == 1 && isempty(obj{1})
    nObj = 1;
else
    nObj = length(vcGetObjects(objType)) + 1;
end

newName = sprintf('%s%.0f', objType, nObj);

return;
