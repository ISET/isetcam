function nObj = vcCountObjects(objType)
%Count how many objects of a type are contained in vcSESSION
%
% Synopsis:
%  nObj = vcCountObjects(objType)
%
% Input
%   obj:  A cell array? of objects.
%
% Description
%   This routine returns the number of objects of objType in the vcSESSION
%   structure. If the structure is empty, 0 is return.
%
% Copyright ImagEval Consultants, LLC, 2003.

obj = vcGetObjects(objType);
if isempty(obj) || isempty(obj{1})
    nObj = 0;
else
    nObj = length(obj);
end

end
