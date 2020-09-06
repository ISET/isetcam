function ax = ieAxisGet(obj,varargin)
% Return the image axis in a window of one of the major ISETCam types
%
% Syntax
%  ax = ieAxisGet(obj,varargin)
%
% Inputs
%  obj - Either a string or an ISETCam object with a .type slot
%
% Optional key/value pair
%   N/A
%
% Returns
%   ax - Handle to the axis in the window
%
% Wandell, January 24 2020
%
% See also
%   vcGetFigure
%

%%
% varargin = ieParamFormat(varargin);

p = inputParser;
vFunc = @(x)(ischar(x) || (isstruct(x) && isfield(x,'type')));
p.addRequired('isetobj',vFunc);

%%  Get the type string if it is a struct

if isstruct(obj)
    tmp = obj; clear obj; 
    obj = vcEquivalentObjtype(tmp.type); 
end

%% Switch through the cases

% See vcGetFigure for another approach.  Fix in ieROIDraw.
switch lower(vcEquivalentObjtype(obj))
    case 'scene'
        app = ieSessionGet('scene window');
        ax  = app.sceneImage;
    case 'opticalimage'
        app = ieSessionGet('oi window');
        ax  = app.oiImage;
    case 'isa'
        app = ieSessionGet('sensor window');
        ax  = app.imgMain;
    case 'vcimage'
        disp('Implement ip in ieAxisGet');
        error('Not yet implemented');
    case 'display'
        disp('Implement display in ieAxisGet');
        error('Not yet implemented');    
    otherwise
        error('Unknown iset object type %s\n',isetobj);
end

end
