function val = ieSessionGet(param,varargin)
% Get fields from global vcSESSION, including figure handles, guidata ...
%
% Synopsis
%     val = ieSessionGet(param,varargin);
%
% Description:
%  The vcSESSION parameter is a global variable that contains information
%  about the windows, custom processing routines, and related ISET
%  session information. ieSessionGet retrieves that information.  
%
%  A list of the parameters is:
%
%      {'version'}
%      {'name','session name'}
%      {'dir','session dir'}
%      {'help','init help'}
%
%  Matlab pref variables
%      {'prefs'}      - Print out the preferences
%      {'font size'}  - Font size in all GUI windows
%      {'wait bar'}   - Show compute waitbars or not
%      {'wpos'}       - Default GUI window positions and sizes
%      {'init clear'} - Clear all variables with ieInit (true)
%
%  Figure handles
%      {'main window'}    - Handle to the figure of main window
%      {'scene window'}   - Handle to the figure of scene window
%      {'oi window'}      - You get the idea ....
%      {'sensor window'}
%      {'ip window'}
%      {'display window'}
%      {'metrics window'}
%      {'graphwin figure'} - Rarely used
%
% Objects properties  (ieSessionGet(param,objType))
%      {'summary'}   - Summarize what is in the database
%      {'selected'}  - Which is currently selected objtype
%      {'nobjects'}  - How many objects of a type.
%          ieSessionGet('nobjects','sensor')
%      {'names'}     - Names of the objects of a type
%          ieSessionGet('names','sensor')
%
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ieAppGet(obj);
%

% Examples
%   NOT UPDATED YET
%
%   h = ieSessionGet('scene window handle')
% 
%   ieSessionSet('wait bar','on');
%   ieSessionGet('wait bar')
%
%   ieSessionGet('font size'); 
%
%   % Clear flag when running ieInit
%   ieSessionGet('init clear')  % True or false
%
%   % Run certain waitbars during calculations
%   ieSessionGet('wait bar')  % True or false
%
%   % Guidata
%   oig = ieSessionGet('oi guidata');
%   ieSessionGet('oi gamma')
%   ieSessionGet('scene display flag')
%
%   oig = ieSessionGet('oi window');
%   % Position is lower left (x,y) and (width, height)
%   set(oig,'position',[0.15    0.3    0.28    0.37])
%
%   ieSessionGet('nobjects','sensor')

%% Parameters
global vcSESSION

if ~exist('param','var')||isempty(param), error('You must specify a parameter.'); end
val = [];

% Eliminate spaces and make lower case
param = ieParamFormat(param);

%% Main switch statement

switch param
    case {'version'}
        val = vcSESSION.VERSION;
    case {'name','sessionname'}
        val = vcSESSION.NAME;
    case {'dir','sessiondir'}
        val = vcSESSION.DIR;
    case {'help','inithelp'}
        % Default for help is true, if the initHelp has not been set.
        % I don't know what this does.
        if checkfields(vcSESSION,'initHelp'), val = vcSESSION.initHelp; 
        else, vcSESSION.initHelp = 1; val = 1; 
        end
        
    % Matlab setpref/getpref 
    case {'prefs'}
        val = getpref('ISET');
    case {'fontsize'}
        isetPref = getpref('ISET');
        if checkfields(isetPref,'fontSize'), val = isetPref.fontSize;
        else, val = 12;
        end
        
    case {'fontincrement','increasefontsize','fontdelta','deltafont'}
        % This should be deprecated
        warning('font delta called.');
        % This value determines whether we change the font size in every window
        % by this increment, calling ieFontChangeSize when the window is
        % opened.
        % if checkfields(vcSESSION,'FONTSIZE'), val = vcSESSION.FONTSIZE;  end
        isetPref = getpref('ISET');
        if ~isempty(isetPref)
            if checkfields(isetPref,'fontDelta'), val = isetPref.fontDelta; 
            end
        else 
            val = 0; 
        end
        if isempty(val), val = 0; end
        
    case {'waitbar'}
        % Used to decide whether we show the waitbars.
        if checkfields(vcSESSION,'GUI','waitbar')
            val = vcSESSION.GUI.waitbar;
        else
            % The getpref is slow.  So, we attach it to the session 
            % at start up.  Otherwise, loops that test for it take too
            % long.
            iePref = getpref('ISET');
            if ~checkfields(iePref,'waitbar')
                setpref('ISET','waitbar',0);
                val = 0;
            else, val = iePref.waitbar;
            end
            vcSESSION.GUI.waitbar = val;
        end
    case {'windowpositions','wpos'}
        % Returns preferred window positions and sizes
        % If that has not yet been set, returns the positions and sizes of
        % the currently open windows.
        isetp = getpref('ISET');
        if checkfields(isetp,'wPos'),  val = isetp.wPos;
        else
            wPos = cell(1,6);
            for ii=1:6, wPos{ii} = []; end
            setpref('ISET','wPos',wPos);
            val = wPos;
        end
        
    case {'initclear'}
        % Clear workspace variables with ieInit.  True or False.
        iePref = getpref('ISET');
        if ~checkfields(iePref,'initclear')
            setpref('ISET','initclear',true);
            val = true;
        else, val = iePref.initclear;
        end
        
    case {'mainwindow','mainfigure','mainfigures'}
        if checkfields(vcSESSION,'GUI','vcMainWindow')
            val = vcSESSION.GUI.vcMainWindow.hObject;
        end
    case {'scenewindow','scenefigure','sceneimagefigure','sceneimagefigures'}
        if checkfields(vcSESSION,'GUI','vcSceneWindow')
            val = vcSESSION.GUI.vcSceneWindow.app;
            % val = app.figure1;
            % val = vcSESSION.GUI.vcSceneWindow.hObject;
        end
    case {'oiwindow','oifigure','opticalimagefigure','oifigures','opticalimagefigures'}
        if checkfields(vcSESSION,'GUI','vcOptImgWindow')
            val = vcSESSION.GUI.vcOptImgWindow.app;
        end
    case {'sensorwindow','sensorfigure','isafigure','sensorfigures','isafigures','isawindow'}
        if checkfields(vcSESSION,'GUI','vcSensImgWindow')
            val = vcSESSION.GUI.vcSensImgWindow.app;
        end
    case {'ipwindow','ipfigure','vcimagefigure','vcimagefigures','vcimagewindow'}
        if checkfields(vcSESSION,'GUI','vcImageWindow')
            val = vcSESSION.GUI.vcImageWindow.app;
        end
    case {'displaywindow'}
        if checkfields(vcSESSION,'GUI','vcDisplayWindow')
            val = vcSESSION.GUI.vcDisplayWindow.app;
        end
    case {'metricswindow','metricsfigure','metricsfigures'}
        if checkfields(vcSESSION,'GUI','metricsWindow')
            val = vcSESSION.GUI.metricsWindow.app;
        end
    case {'camdesignwindow'}
        if checkfields(vcSESSION,'GUI','vcCamDesignWindow')
            val = vcSESSION.GUI.vcCamDesignWindow.app;
        end
    case {'imageexplorewindow'}
        if checkfields(vcSESSION,'GUI','vcImageExploreWindow')
            val = vcSESSION.GUI.vcImageExploreWindow.app;
        end
        
        % Information about current objects
        % ieSessionGet('scene');
        % and so forth
    case {'scene'}
        val = vcGetObject('scene');
    case {'oi','opticalimage'}
        val = vcGetObject('oi');
    case {'sensor','isa'}
        val = vcGetObject('sensor');
    case {'vcimage','ip'}
        val = vcGetObject('ip');
    case {'selected'}
        % ieSessionGet('selected',objType)
        if isempty(varargin), error('Please specify object type'); end
        val = vcGetSelectedObject(varargin{1});
    case {'nobjects'}
        % ieSessionGet('n objects',objType);
        if isempty(varargin), error('Please specify object type'); end
        switch vcEquivalentObjtype(varargin{1})
            case {'SCENE'}
                val = length(vcSESSION.SCENE);
            case {'OPTICALIMAGE'}
                val = length(vcSESSION.OPTICALIMAGE);
            case {'ISA'}
                val = length(vcSESSION.ISA);
            case {'VCIMAGE'}
                val = length(vcSESSION.VCIMAGE);
        end
    case {'names'}
        % ieSessionGet('names',objType)
        if isempty(varargin), error('Please specify object type'); end
        val = vcGetObjectNames(vcEquivalentObjtype(varargin{1})); 
        
        % DISPLAY related - may be moved out of here
    case {'imagesizethreshold'}
        % Used by the display code.  This sets a value for when we loop
        % over wavelength instead of doing a large matrix multiplication.
        % HJ - more comments later.
        if isfield(vcSESSION, 'imagesizethreshold')
            val = vcSESSION.imagesizethreshold;
        else
            val = 1e6;
        end

    otherwise
        error('Unknown parameter %s\n',param)
        
end

end
