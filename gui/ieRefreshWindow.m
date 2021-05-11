function app = ieRefreshWindow(objType)
% Refresh one of the four types of windows
%
% Synopsis
%   app = ieRefreshWindow(objType)
%
% Input
%  objType:  A string defining the object type.  If obj is an ISETCam
%            struct, then this could be obj.type
%
% Output
%   app:     The window app
%
%Purpose:
%  Issue a refresh to one of the ISET windows.  This routine is useful when
%  you have changed the data and would like the window to update according
%  to the new data.
%
% Example:
%    ieReplaceObject(scene); ieRefreshWindow('scene');
%    ieReplaceObject(obj);   ieRefreshWindow(obj.type);
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   ieSessionGet

if ieNotDefined('objType'), error('You must specify an object type.'); end

objType = vcEquivalentObjtype(objType);

switch lower(objType)
    case {'scene'}
        app = ieSessionGet('scene window');
    case {'opticalimage', 'oi'}
        app = ieSessionGet('oi window');
    case {'isa', 'sensor'}
        app = ieSessionGet('sensor window');
    case {'vcimage', 'ip'}
        app = ieSessionGet('ip window');
    otherwise
        error('Unknown object type');
end

app.refresh;

end
