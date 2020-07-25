function hdl = ieRefreshWindow(objType)
%Refresh one of the four types of windows
%
% Synopsis
%   ieRefreshWindow(objType)
%
% Input
%  objType:  A string defining the object type.  If obj is an ISETCam
%            struct, then this could be obj.type 
%
% Output
%   hdl:     Handle to the window
%
%Purpose:
%   Issue a refresh to one of the ISET windows.  This routine is useful
%   when you have changed the data and would like the window to update
%   according to the new data.
%
% Example:
%    ieReplaceObject(scene); ieRefreshWindow('scene');
%    vcReplaceObject(oi); ieRefreshWindow('opticalimage');
%    vcReplaceObject(isa); ieRefreshWindow('sensor');
%    vcReplaceObject(vcimage); ieRefreshWindow('vcimage');
%    ieReplaceObject(obj); ieRefreshWindow(obj.type);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('objType'), error('You must specify an object type.'); end

objType = vcEquivalentObjtype(objType);

switch lower(objType)
    case {'scene'}
        hdl = sceneWindow; 

    case {'opticalimage','oi'}
        hdl = oiWindow; 
       
    case {'isa','sensor'}
        hdl = sensorImageWindow; 
        
    case {'vcimage','ip'}
        hdl = ipWindow; 
        
    otherwise
        error('Unknown object type');
end

end
