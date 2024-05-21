function ieSelectObject(objType,val)
% Set selected object in vcSESSION variable.
%
%   ieSelectObject(objType,val)
%
%  Sets the currently selected object, where the ISET object type might be
%  SCENE,OPTICALIMAGE,ISA, and VCIMAGE.
%
%  If val is 0 (or less than one) the selected value is set to empty.  If
%  it is a positive integer, then we check that it is in range of the
%  number of objects of that type, warn if it isn't, and go ahead and set
%  the value.
%
% Examples:
%  vcSetSelectedObject('SCENE',1)
%  vcSetSelectedObject('OPTICALIMAGE',3);
%  vcSetSelectedObject('OPTICALIMAGE',3);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
%  See also;
%    ieAddObject, vcNewObjectValue
%

% TODO:
%  We should eliminate these routines and instead do the work through
%  switch statements that go to ieSessionSet

global vcSESSION; %#ok<NUSED>

% Make sure we have the correct string
objType = vcEquivalentObjtype(objType);

if logical(isempty(val)) || logical(val < 1)
    % No object is selected.
    eval(['vcSESSION.SELECTED.',objType,'= [];'])
else
    % Select the object.
    nObjects = length(vcGetObjects(objType));
    if val <= nObjects
        eval(['vcSESSION.SELECTED.',objType,'= val;']);
    else
        error('Selected object out of range.');
    end
end

end