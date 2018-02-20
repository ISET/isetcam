function val = ieFindObjectByName(objType,objName)
%Return an object number given its type and name
%
%    val = ieFindObjectByName(objType,objName)
%
% Purpose:
%    Find the object of objType with name of objName.  Return its slot in
%    the cell array within vcSESSION.
%
% Examples:
%   val = ieFindObjectByName('vcimage','mono1')
%
% Copyright ImagEval Consultants, LLC, 2003.

obj = vcGetObjects(objType);
if length(obj) == 1 & isempty(obj{1})
    warning(sprintf('No objects of type %s',objType));
    return;
end

val = [];
for ii=1:length(obj)
    if strcmp(obj{ii}.name,objName)
        val = ii;
        return;
    end
end

return;