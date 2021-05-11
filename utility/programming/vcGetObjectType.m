function objType = vcGetObjectType(obj)
% Return the type of ISET object.
%
%   objType = vcGetObjectType(obj)
%
%   The set of types includes:  SCENE, OPTICALIMAGE, ISA, VCIMAGE, PIXEL
%   and OPTICS. This routine will perform the task properly for any
%   structure that as a .type field.
%
% Examples:
%  oi = vcGetObject('oi');
%  vcGetObjectType(oi)
%
%  obj = oiGet(oi,'optics');
%  vcGetObjectType(obj)
%
% Copyright ImagEval Consultants, LLC, 2005.

if checkfields(obj, 'type'), objType = obj.type;
    return;
else, error('Object does not have a type field.');
end

end
