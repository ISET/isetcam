function [val, sOBJECT] = ieGetSelectedObject(objType)
%Returns the number of the currently selected object of some type
%
%   [val,sOBJECT] = ieGetSelectedObject(objType)
%
% This routine returns both the number and object itself, if requested. You
% may wish to use vcGetObject(objType) in general.  That routine returns
% the currently selected object, of objType.
%
% The set of possible objects returned are:
%
%   SCENE, PIXEL, OPTICS, {OPTICALIMAGE,OI}, VCIMAGE, GRAPHWIN, {ISA, SENSOR}
%
%  Originally, this routine was the main one used to return objects.
%
%  val = ieGetSelectedObject('SCENE')
% [val, pixel] = ieGetSelectedObject('PIXEL')
% [val, sensor] = ieGetSelectedObject('SENSOR')
% [val, vci] = ieGetSelectedObject('VCIMAGE')
% [val, vci] = ieGetSelectedObject('IMGPROC')
% [val, display] = ieGetSelectedObject('DISPLAY')
%
% As of May 2004, I started using
%    obj = ieGetObject(objType)
%    obj = ieGetObject(objType,val)
%
% Currently, I only use this routine if I need the val
%
%    val = ieGetSelectedObject('foo')
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

objType = vcEquivalentObjtype(objType);

switch lower(objType)
    case 'scene'
        if checkfields(vcSESSION, 'SELECTED', 'SCENE'), val = vcSESSION.SELECTED.SCENE; end
    case {'opticalimage', 'oi'}
        if checkfields(vcSESSION, 'SELECTED', 'OPTICALIMAGE'), val = vcSESSION.SELECTED.OPTICALIMAGE; end
    case {'optics'}
        if checkfields(vcSESSION, 'SELECTED', 'OPTICALIMAGE'), val = vcSESSION.SELECTED.OPTICALIMAGE; end
    case {'isa', 'sensor'}
        if checkfields(vcSESSION, 'SELECTED', 'ISA'), val = vcSESSION.SELECTED.ISA; end
    case {'vcimage', 'ip', 'imgproc'}
        if checkfields(vcSESSION, 'SELECTED', 'VCIMAGE'), val = vcSESSION.SELECTED.VCIMAGE; end
    case {'pixel'}
        if checkfields(vcSESSION, 'SELECTED', 'ISA'), val = vcSESSION.SELECTED.ISA; end
    otherwise,
        error('Unknown object type.');
end


if nargout == 2
    sOBJECT = vcGetObject(objType, val);
end

return
