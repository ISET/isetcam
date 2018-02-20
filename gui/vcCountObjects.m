function nObj = vcCountObjects(objType)
%Count how many objects of a type are contained in vcSESSION
%
%  nObj = vcCountObjects(objType)
%
%Purpose:
%   This routine returns the number of objects of objType in the vcSESSION
%   structure. If the structure is empty, 0 is return.
%
% Copyright ImagEval Consultants, LLC, 2003.

obj = vcGetObjects(objType);
if isempty(obj{1})
    nObj = 0;
else
    nObj = length(obj);
end

return;

