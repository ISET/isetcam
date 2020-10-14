function [val,sOBJECT] = vcGetSelectedObject(objType)
%Returns the number of the currently selected object of some type
%
%   [val,sOBJECT] = vcGetSelectedObject(objType)
%
% This routine returns both the number and object itself, if requested. You
% may wish to use vcGetObject(objType) in general.  That routine returns
% the currently selected object, of objType.
%
% The set of possible objects returned are:
%
%   SCENE, PIXEL, OPTICS, {OPTICALIMAGE,OI}, VCIMAGE, GRAPHWIN, {ISA,
%   SENSOR}, DISPLAY, IPDISPLAY
%
%  Originally, this routine was the main one used to return objects.
%
%  val = vcGetSelectedObject('SCENE')
% [val, pixel] = vcGetSelectedObject('PIXEL')
% [val, sensor] = vcGetSelectedObject('SENSOR')
% [val, vci] = vcGetSelectedObject('VCIMAGE')
% [val, vci] = vcGetSelectedObject('IMGPROC')
% [val, display] = vcGetSelectedObject('DISPLAY')
%
% As of May 2004, I started using
%    obj = vcGetObject(objType)
%    obj = vcGetObject(objType,val)
%
% Currently, I only use this routine if I need the val
%
%    val = vcGetSelectedObject('foo')
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

objType = vcEquivalentObjtype(objType);

% If the slot is empty, we return an empty val
val = [];

switch lower(objType)
    case 'scene'
        if checkfields(vcSESSION,'SELECTED','SCENE'), val = vcSESSION.SELECTED.SCENE;  end
    case {'opticalimage','oi','optics'}
        % Gets the OI or the optics attached to the oi
        if checkfields(vcSESSION,'SELECTED','OPTICALIMAGE'), val = vcSESSION.SELECTED.OPTICALIMAGE;  end
    case {'isa','sensor','pixel'}
        % Gets the sensor or the pixel attached to the sensor
        if checkfields(vcSESSION,'SELECTED','ISA'), val = vcSESSION.SELECTED.ISA;  end
    case {'vcimage','ip','imgproc','ipdisplay'}
        % Gets the ip or the display attached to the ip
        if checkfields(vcSESSION,'SELECTED','VCIMAGE'), val = vcSESSION.SELECTED.VCIMAGE;  end
    case {'display'}
        % This is a real display object, as in the displayWindow
        if checkfields(vcSESSION,'SELECTED','VCIMAGE'), val = vcSESSION.SELECTED.DISPLAY;  end
    otherwise
        error('Unknown object type.');
end


if nargout == 2
    sOBJECT = vcGetObject(objType,val);
end

end
