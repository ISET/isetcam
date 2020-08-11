function vcSetSelectedObject(objType,val)
% Set selected object in vcSESSION variable.
%
%   vcSetSelectedObject(objType,val)
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
%  See also;
%    ieAddObject, vcNewObjectValue
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:
%  We should eliminate these routines and instead do the work through
%  switch statements that go to ieSessionSet

global vcSESSION; %#ok<NUSED>

objType = vcEquivalentObjtype(objType);

if logical(isempty(val)) || logical(val < 1)   % BW - 2020
    eval(['vcSESSION.SELECTED.',objType,'= [];'])
else
    nObjects = length(vcGetObjects(objType));
    if val <= nObjects
        eval(['vcSESSION.SELECTED.',objType,'= val;']);
    else
        error('Selected object out of range.');
    end
end


return;
