function ieSessionSet(param,val,varargin)
% Set vcSESSION parameters.
%
%     ieSessionSet(param,val,varargin);
%
% While vcSESSION parameters are often set by this routine, there remain
% places in the code where vcSESSION is touched directly or where we use
% the many legacy functions (vcSet<mumble>).  I am trying to clean this up
% slowly over time.
%
% Session parameters
%   'version'  - ISET version
%   'session name' - Name of the session (rarely used)
%   'session dir'  - Name of the directory where session is stored (rare)
%   'init help'
%
% Matlab setpref variables
%   'font size' - This value determines whether we set the
%       font size in every window, calling
%       ieFontChangeSize when the window is opened.
%   'window positions' - Window positions and size (see below)
%   'wait bar'   - Show waitbars (or not) during certain long computations
%   'init clear' - Clear variables when calling ieInit
%
% Figure handles
%    'main window'    - Store handles for main window
%    'scene window'   - Store handles for scene window
%    'oi window'      - Store handles of optical image window
%    'sensor window'  - Store handles for sensor window
%    'ip window'      - Store handles for image processor
%                         (virtual camera image) window
%    'metrics window'  - Store handles for metrics window
%    'graphwin val'    - Number for graphics window
%    'graphwin handle' - Not currently used, in future will be as named
%    'graphwin figure' - hObject for graphics window.  Why is this not
%          handle?
%
% Window GUI properties
%    'scene gamma'  - Gamma display value for scene window (e.g., 0.5)
%    'scene display flag' - 1 = RGB, 2 = Gray, 3 = HDR, 4 = Clip Highlights
%    'oi gamma'     - Gamma display value for 
%    'oi display flag' - 1 = RGB, 2 = Gray, 3 = HDR, 4 = Clip Highlights
%    'sensor gamma'
%    'ip gamma'
%
% Current objects
%     'scene'
%     'oi'
%     'sensor'
%     'ip'
%
% Example:
%    ieSessionSet('scene gamma'0.3);
%    ieSessionSet('wait bar',false);
% 
% See also: ieSessionGet, vcSetObject
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Parameters
global vcSESSION

if ~exist('param','var')||isempty(param), error('You must specify a parameter.'); end
if ~exist('val','var'),   error('You must specify a value.');     end

%% Main switch
param = ieParamFormat(param);
switch param
    case {'version'}
        vcSESSION.VERSION = val;
    case {'name','sessionname'}
        vcSESSION.NAME = val;
    case {'dir','sessiondir'}
        vcSESSION.DIR = val;
    case {'help','inithelp'}
        % Default for help is true, if the initHelp has not been set.
        if checkfields(vcSESSION,'initHelp'), vcSESSION.initHelp = val;
        else, vcSESSION.initHelp = 1; 
        end
        
        % Matlab setpref values
        %     case {'deltafontsize','fontincrement','increasefontsize','fontdelta','deltafont'}
        %         % Deprecated
        %         setpref('ISET','fontDelta',val);
    case {'fontsize'}
        % GUI window font size
        setpref('ISET','fontSize',val);
    case {'waitbar'}
        % 0 means off, 1 means on
        if ischar(val)
            switch val
                case 'on',  val = 1;
                case 'off', val = 0;
            end
        end
        setpref('ISET','waitbar',val);
        % Because getpref is slow, we also attach it to the session.  Then
        % looping and checking doesn't cost us much time.
        vcSESSION.GUI.waitbar = val;
    case {'wpos','windowpositions'}
        % GUI window position and size preferences
        % val should be a cell array, length 6, each 1 x 4, with values
        % that are the relative position of the window on the screen, as
        % used by set(w,'Position',pos);  
        %
        % For example, pos might be [0.1 0.45 0.32 0.41];
        %
        % 1 - 'main window'
        % 2 - 'scene window'
        % 3 - 'oi window'
        % 4 - 'sensor window'
        % 5 - 'ip window'
        % 6 - 'graph window'
        %
        if iscell(val) && length(val) == 6, setpref('ISET','wPos',val);
        else, error('Bad wPos variable, %f', val);
        end
        
    case {'initclear'}
        % Clear workspace variables with ieInit.  True or False.
        setpref('ISET','initclear',logical(val));
        
        % Set window information at startup
    case {'mainwindow'}
        vcSESSION.GUI.vcMainWindow.app = val;
    case {'scenewindow'}
        % We are now just storing the whole app struct
        vcSESSION.GUI.vcSceneWindow.app = val;
    case {'oiwindow'}
        vcSESSION.GUI.vcOptImgWindow.app = val;
    case {'sensorwindow'}
        vcSESSION.GUI.vcSensImgWindow.app = val;
    case {'vcimagewindow','ipwindow'}
        vcSESSION.GUI.vcImageWindow.app = val;
    case {'displaywindow'}
        vcSESSION.GUI.vcDisplayWindow.app = val;
        
        % Refresh image window
        % Putting this in the display object itself, not here
        %{
    case {'displayimage','imgdata'}
        if ~ndims(val) == 3
            error('Data do not appear to be an RGB image');
        else
            vcSESSION.imgData = val;
        end
        %}
    case {'metricswindow'}
        if length(varargin) < 2, error('metrics window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.metricsWindow.hObject = val;
        vcSESSION.GUI.metricsWindow.eventdata = varargin{1};
        vcSESSION.GUI.metricsWindow.handles = varargin{2};
        
        % This graphics window stuff is a mess.  We usually store data using
        % set(gcf,'userdata',XXX) not the guidata.
    case {'graphwindow','graphwinfigure'}
        % This is just the figure number, usually.
        vcSESSION.GRAPHWIN.hObject = val;
        
        % Maybe these should just go away?
    case {'graphwinstructure','graphwinval'}
        vcSESSION.GRAPHWIN = val;
    case {'graphwinhandle'}
        % At present we don't add any objects with handles.  So this is
        % empty. But we might some day.
        vcSESSION.GRAPHWIN.handle = val;
    %{
        % Manage the screen gamma values.  Also brings up the window.  Not
        % sure if that is right.
    case {'scenegamma'}
        % ieSessionSet('scene gamma',0.5);
        scg = ieSessionGet('scene guidata');
        if ~isempty(scg), set(scg.editGamma,'string',num2str(val,'%.1f')); end
        sceneWindow;
    case {'scenedisplayflag'}
        sg = ieSessionGet('scene guidata');
        if ~isempty(sg), set(sg.popupDisplay,'value',val); end
        sceneWindow;
    case {'oigamma'}
        oig = ieSessionGet('oi guidata');
        if ~isempty(oig), set(oig.editGamma,'string',num2str(val,'%.1f')); end
        oiWindow;
    case {'oidisplayflag'}
        oig = ieSessionGet('oi guidata');
        if ~isempty(oig),set(oig.popupDisplay,'value',val); end
        oiWindow;
    case {'sensorgamma'}
        % Note the wrong field name, editGam, not editGamma, sigh.
        seg = ieSessionGet('sensor guidata');
        if ~isempty(seg), set(seg.editGam,'string',num2str(val,'%.1f')); end
        sensorWindow;
    case {'ipgamma','vcigamma'}
        ipg = ieSessionGet('ip guidata');
        if ~isempty(ipg), set(ipg.editGamma,'string',num2str(val,'%.1f')); end
        ipWindow;
        %}
        % Set selected object
        % ieSessionSet('scene',val);
        % and so forth
    case {'scene'}
        vcSetSelectedObject('scene',val);
    case {'oi','opticalimage'}
        vcSetSelectedObject('oi',val);
    case {'sensor','isa'}
        vcSetSelectedObject('sensor',val);
    case {'vcimage','ip'}
        vcSetSelectedObject('ip',val);
    case {'display'}
        vcSetSelectedObject('display',val);
        
        % Miscellaneous from HJ code
    case {'gpu', 'gpucompute', 'gpucomputing'}
        vcSESSION.GPUCOMPUTE = val;
    case {'imagesizethreshold'}
        vcSESSION.imagesizethreshold = val;
        
    otherwise
        error('Unknown parameter')
end
