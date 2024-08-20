function ipW = ipWindow(ip,varargin)
% Wrapper that replaces the GUIDE oiWindow functionality
%
% Synopsis
%   ipW = ipWindow(ip,varargin)
%
% Brief description
%   Opens an ipWindow interface based on the ipWindow_App.
%
% Inputs
%   ip:  The image processor you want in the window.  If empty, the currently
%        selected ip in global vcSESSION is used.  If there is no
%        selected ip a default ip is created and used.
%
% Optional key/val pairs
%
%   show:   Executes a drawnow command on exiting.
%           (default true)
%   replace: Logical.  If true, then replace the current oi, rather than
%            adding the oi to the database.  Default: false
%   render flag:  'rgb','hdr','gray'
%   gamma:    Display gamma, typically [0-1] 
%
%
% Outputs
%   ipW:  An ipWindow_App object.
%
% Description
%
%  If there is a ipWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The ipWindow_App all show any of the ips stored in the vcSESSION.IP
%  database slot.
%
% See also
%    sceneWindow_App, oiWindow_App
%

% Examples
%{
   ipWindow;
%}
%{
   scene = sceneCreate;
   oi = oiCreate;  oi = oiCompute(oi,scene);
   oiWindow(oi);
%}

%% Add a sensor to the database if it is in the call

varargin = ieParamFormat(varargin);

if ~exist('ip','var') || isempty(ip)
    % Get the currently selected scene
    ip = ieGetObject('ip');
    if isempty(ip)
        % There are no ois. We create the default oi and add it to
        % the database
        ip = oiCreate;
        ieAddObject(ip);
    end
end

p = inputParser;
p.addRequired('ip',@(x)(isstruct(x) && isequal(x.type,'vcimage')));
p.addParameter('show',true,@islogical);
p.addParameter('replace',false,@islogical);
p.addParameter('renderflag',[],@ischar);
p.addParameter('gamma',[],@isscalar);

p.parse(ip,varargin{:});

%% An ip was passed in. 

if isempty(ip.data.input)
    warning('No image data.  Returning without adding this empty ip to the window.');
    return;
end

% We add it to the database and select it.
% That oi will appear in the oiWindow.
if p.Results.replace, ieReplaceObject(ip);
else,                 ieAddObject(ip);
end

%% See if there is a window.

ipW = ieSessionGet('ip window');

if isempty(ipW)
    % Empty, so create one and put it in the vcSESSION
    ipW = ipWindow_App;
    ieSessionSet('ip window',ipW);
elseif ~isvalid(ipW)
    % Replace the invalid one
    ipW = ipWindow_App;
    ieSessionSet('ip window',ipW);
else
    % Just refresh it
    ipW.refresh(ip);
end


%% Display settings

if ~isempty(p.Results.renderflag)
    ip = ipSet(ip,'render flag',p.Results.renderflag);
    ieReplaceObject(ip);
end

if ~isempty(p.Results.gamma)
    ip = ipSet(ip,'gamma',p.Results.gamma);
    ieReplaceObject(ip);
end

if p.Results.show, drawnow; end

end
