function [obj,nObj] = vcGetObjects(objType)
%Retrieve cell larray of objects of objType
%
%  [obj,nObj] = vcGetObjects(objType)
%
%   Return the cell array of a particular type of object.  Optionally, the
%   total number of objects of this type is returned, too.
%
%  See Also:  vcGetObject, vcGetSelectedObject
%
% Examples:
%  obj = vcGetObjects('PIXEL');
%  [obj, nObj] = vcGetObjects('SCENE');
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION;

% Translate various names into the proper name used in vcSESSION.
% This routine also forces upper case on the object type, as required.
objType = vcEquivalentObjtype(objType);

if checkfields(vcSESSION,objType),  eval(['obj = vcSESSION.',objType,';']);
else                                obj{1} = []; 
end

if nargout == 2, nObj = length(obj); end

return