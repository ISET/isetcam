function val = ieSessionGet(param,varargin)
% Get fields from global vcSESSION, including figure handles, guidata ...
%
%     val = ieSessionGet(param,varargin);
%
%  The vcSESSION parameter is a global variable that contains information
%  about the windows, custom processing routines, and related ISET
%  session information.
%
%  This get routine retrieves that information.  The information is stored
%  in a global variable for now.  In the future, this information will be
%  obtained using findobj().
%
%  The tag 'handle' refers to the guihandles.  The tag 'figure' refers to
%  the figure number.  The guidhandles can be retrieved by using 
%  h = guihanles(f);
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
%   Axis handles  - These are the axes (images) in the windows. There is
%   one main image in each, and the case when there is more than one
%   (display) we will handle differently later.
%     {'scene axis'}        - Scene
%     {'oi axis'}           - Optical image
%     {'sensor axis'}       - Sensor
%     {'ip axis'}           - Image processing
%
% Guidata
%      {'main guidata'}   - Guidata of Main window
%      {'scene guidata'}  - Guidata from scene window 
%      {'oi guidata'}     - ...
%      {'sensor guidata'}
%      {'ip guidata'}
%      {'display guidata'}
%      {'metrics guidata'}
%      {'graphwin guidata'}
%
% Objects properties  (ieSessionGet(param,objType))
%      {'selected'}  - Which is currently selected objtype
%      {'nobjects'}  - How many objects of a type.
%          ieSessionGet('nobjects','sensor')
%      {'names'}     - Names of the objects of a type
%          ieSessionGet('names','sensor')
%
% Window settings
%      {'scene gamma'}    - Gamma for scene window display, ...
%      {'scene display flag'} - RGB, HDR, Gray scale
%
%      {'oi gamma'}
%      {'oi display flag'} - RGB, HDR, Gray scale
%
%      {'sensor gamma'}
%      {'ip gamma'}
%
% Current objects
%
% Examples:
%   h = ieSessionGet('scene window handle')
%   g = ieSessionGet('scene guidata')
%   (N.B. g = guidata(h)) 
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
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Parameters
global vcSESSION

if ieNotDefined('param'), error('You must specify a parameter.'); end
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
        
    % Figure handles to the various windows.  
    % vcNewGraphWin, main, scene, oi, sensor, ip
    case {'graphwindow','graphfigure'}
        if checkfields(vcSESSION,'GRAPHWIN','hObject') 
            val = vcSESSION.GRAPHWIN.hObject; 
        end  
    case {'graphguidata'}
        if checkfields(vcSESSION,'GRAPHWIN','handle') 
            val = guidata(ieSessionGet('graph window')); 
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
        
        %{
        % Handles to the guidata in the windows
    case {'mainguidata','mainwindowhandle','mainhandle','mainhandles'}
        v = ieSessionGet('mainfigure');
        if ~isempty(v), val = guihandles(v); end
    case {'sceneguidata','scenewindowhandle','scenehandle','sceneimagehandle','scenehandles','sceneimagehandles','scenewindowhandles'}
        v = ieSessionGet('sceneimagefigure');
        if ~isempty(v), val = guihandles(v); end
    case {'oiguidata','oiwindowhandle','oihandle','opticalimagehandle','oihandles','opticalimagehandles','oiwindowhandles'}
        v = ieSessionGet('opticalimagefigure');
        if ~isempty(v), val = guihandles(v); end
    case {'sensorguidata','sensorwindowhandle','sensorimagehandle','sensorhandle','isahandle','sensorhandles','isahandles','sensorwindowhandles'}
        v = ieSessionGet('sensorfigure');
        if ~isempty(v), val = guihandles(v); end
    case {'ipguidata','iphandles','vciguidata','vciwindowhandle','vcimagehandle','vcimagehandles','processorwindowhandles','processorhandles','processorhandle','processorimagehandle'}
        v = ieSessionGet('vcimagefigure');
        if ~isempty(v), val = guihandles(v); end
    case {'displayguidata'}
        v = ieSessionGet('display window');
        if ~isempty(v), val = guihandles(v); end
    case {'metricguidata','metricshandle','metricshandles','metricswindowhandles','metricswindowhandle'}
        v = ieSessionGet('vcimagefigure');
        if ~isempty(v), val = guihandles(v); end
     %}
        
    case {'sceneaxis'}
        % For app design.  All of the others will need updating, too.
        sceneW = ieSessionGet('scene window');
        val = sceneW.sceneImage;
    case {'oiaxis'}
        hdl = ieSessionGet('oiwindow');
        hdl = get(hdl); val = hdl.CurrentAxes;
    case {'sensoraxis'}
        hdl = ieSessionGet('sensorwindow');
        hdl = get(hdl); val = hdl.CurrentAxes;
    case {'ipaxis'}
        hdl = ieSessionGet('ipwindow');
        hdl = get(hdl); val = hdl.CurrentAxes;
        
        % Window data for display
    case {'scenegamma'}
        % ieSessionGet('scene gamma')
        sg = ieSessionGet('scene guidata');
        if ~isempty(sg), val = str2double(get(sg.editGamma,'string')); end
    case {'scenedisplayflag'}
        app = ieSessionGet('scene window');
        if ~isempty(app)
            val = find(contains(app.popupDisplay.Items,app.popupDisplay.Value)); 
        end
    case {'oigamma'}
        % ieSessionGet('oi gamma')
        oig = ieSessionGet('oi guidata');
        if ~isempty(oig), val = str2double(get(oig.editGamma,'string')); end
    case {'oidisplayflag'}
        app = ieSessionGet('oi window');
        if ~isempty(app)
            val = find(contains(app.popupDisplay.Items,app.popupDisplay.Value)); 
        end
    case {'sensorgamma'}
        % ieSessionGet('sensor gamma')
        sensorg = ieSessionGet('sensor guidata');
        if ~isempty(sensorg) 
            val = str2double(get(sensorg.editGam,'string'));  % Not different name
        end        
    case {'ipgamma','vcigamma'}
        % ieSessionGet('ip gamma')
        % ieSessionGet('vci gamma')
        ipg = ieSessionGet('ip guidata');
        if ~isempty(ipg), val = str2double(get(ipg.editGamma,'string')); end
        
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
        % HJ GPU case
    case {'gpu', 'gpucompute', 'gpucomputing'}
        % Whether or not to use gpu compute.  Always false now, but in the
        % future we may do more with this.
        val = false;
    otherwise
        error('Unknown parameter %s\n',param)
        
end

end
