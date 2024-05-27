function vcSetSelectedObject(objType,val)
% Set selected object in vcSESSION variable.
%
% ** Plan to deprecate and replace with ieSelectObject **
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
% Copyright ImagEval Consultants, LLC, 2005.
%
%  See also;
%    ieAddObject, vcNewObjectValue
%

% TODO:
%  We are eliminating these  vc* routines and instead working through
%  switch statements that go to ieSessionSet

ieSelectObject(objType,val);

end

