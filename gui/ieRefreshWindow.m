function ieRefreshWindow(objType)
%Refresh one of the four types of windows
%
%   ieRefreshWindow(objType)
%
%Purpose:
%   Issue a refresh to one of the ISET windows.  This routine is useful
%   when you have changed the data and would like the window to update
%   according to the new data.
%
% Example:
%    vcReplaceObject(scene); ieRefreshWindow('scene');
%    vcReplaceObject(oi); ieRefreshWindow('oi');
%    vcReplaceObject(isa); ieRefreshWindow('isa');
%    vcReplaceObject(vcimage); ieRefreshWindow('vcimage');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('objType'), error('You must specify an object type.'); end

objType = vcEquivalentObjtype(objType);

switch lower(objType)
    case {'scene'}
        h = sceneWindow; 

    case {'opticalimage'}
        h = oiWindow; 
       
    case {'isa'}
        h = sensorImageWindow; 
        
    case {'vcimage'}
        h = ipWindow; 
        
    otherwise
        error('Unknown object type');
end

return;