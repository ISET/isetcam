function vcReplaceAndSelectObject(obj,val)
%Replace an object and set as selected in the vcSESSION variable
%
%   vcReplaceAndSelectObject(obj,[val])
%
% Replace an existing object in the vcSESSION global variable.
% The object type can be SCENE,VCIMAGE,OPTICALIMAGE, or ISA.
% The val should be the value of the object that will be replaced.
%
% If there are no objects in the vcSESSION variable then this one becomes
% the first entry, replacing nothing.
%
% Examples
%  vcReplaceAndSelectObject(oi,3);
%  vcReplaceAndSelectObject(ISA,val);
%
% Copyright ImagEval Consultants, LLC, 2003.


if ieNotDefined('obj'), errordlg('Object must be defined.'); end
objType = vcGetObjectType(obj);

if ieNotDefined('val'), val = vcGetSelectedObject(objType); end
if isempty(val), val = 1; end

vcReplaceObject(obj,val);
vcSetSelectedObject(objType,val);

return;
