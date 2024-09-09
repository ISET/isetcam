function oiW = oiWindow(oi,varargin)
% Wrapper that replaces the GUIDE oiWindow functionality
%
% Synopsis
%   oiW = oiWindow(oi,varargin)
%
% Brief description
%   Opens a oiWindow interface based on the oiWindow_App.
%
% Inputs
%   oi:     The oi you want in the window.  If not sent in or empty (ok),
%           the currently selected oi in global vcSESSION is used. If there
%           is no selected oi a default scene and oi are created and used.
%
% Optional
%   show:   Executes a drawnow command on exiting.
%           (default true)
%   replace: Logical.  If true, then replace the current oi, rather than
%            adding the oi to the database.  Default: false
%   render flag:  'rgb','hdr','clip','monochrome'
%   gamma:    Display gamma, typically [0-1]     
%
% Outputs
%   oiW:  An oiWindow_App object.
%
% Description
%
%  If there is a oiWindow_App stored in the vcSESSION database, this
%  interface opens that app.
%
%  If that slot is empty, this function creates one and stores it in the
%  database.
%
%  Sometimes there is a stale handle to an app in the vcSESSION database.
%  This code tries the non-empty (but potentially stale) app.  If it works,
%  onward. If not, then it creates a new one, stores it, and uses it.
%
%  The oiWindow_App all show any of the ois stored in the vcSESSION.OI
%  database slot.
%
% See also
%    oiWindow_App
%

% Examples
%{
   oiWindow;
%}
%{
   scene = sceneCreate;
   oi = oiCreate;  oi = oiCompute(oi,scene);
   oiWindow(oi);
%}

%% Add the scene to the database if it is in the call

varargin = ieParamFormat(varargin);

if ~exist('oi','var') || isempty(oi)
    % Get the currently selected scene
    oi = ieGetObject('oi');
    if isempty(oi)
        % There are no ois. We create the default oi and add it to
        % the database
        oi = oiCreate;
        ieAddObject(oi);
    else
        % There is a scene in vcSESSION. None was passed in.  So this is a
        % refresh only.
        try
            app = ieAppGet(oi);
        catch
            app = oiWindow_App;
        end
        oiW = oi;
        app.refresh;
        return;
    end
end

p = inputParser;
p.addRequired('oi',@(x)(isstruct(x) && isequal(x.type,'opticalimage')));
p.addParameter('show',true,@islogical);
p.addParameter('replace',false,@islogical);
p.addParameter('renderflag',[],@ischar);
p.addParameter('gamma',[],@isscalar);

p.parse(oi,varargin{:});

%% An oi was passed in. 

% We add it to the database and select it.
% That oi will appear in the oiWindow.
if p.Results.replace, ieReplaceObject(oi);
else,                 ieAddObject(oi);
end

%% See if there is a live window.

oiW = ieSessionGet('oi window');

if isempty(oiW)
    % Empty, so create one and put it in the vcSESSION
    oiW = oiWindow_App;
    ieSessionSet('oi window',oiW);
elseif ~isvalid(oiW)
    % Replace the invalid one
    oiW = oiWindow_App;
    ieSessionSet('oi window',oiW);
else
    % Just refresh it
    oiW.refresh;
end

%%

%% Display settings

% Someday, we may have renderflag and gamma slots in the oi itself.
% So I replace them now after setting, to future-proof.
if ~isempty(p.Results.renderflag)
    oi = oiSet(oi,'render flag',p.Results.renderflag);
    ieReplaceObject(oi);
end

if ~isempty(p.Results.gamma)
    oi = oiSet(oi,'gamma',p.Results.gamma);
    ieReplaceObject(oi);
end

if p.Results.show; drawnow; end

end
