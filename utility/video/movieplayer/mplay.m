function mov = mplay(varargin)
%MPLAY Play a movie interactively.
%   MPLAY(A) opens a new movie player GUI and loads movie data
%   A into the player.  Multiple players may be used at one time.
%
%   MPLAY(A, FMT) explicity specifies a format string FMT for the
%   movie data, in case a warning from MPLAY(A) indicates ambiguity
%   in interpreting the format of A.
%
%   MPLAY(A, FPS) or MPLAY(A, FMT, FPS) specifies the default
%   frame rate, FPS, for the movie, in frames per second.  If
%   omitted, FPS defaults to 30.  The GUI supports interactive
%   changes to FPS as well.
%
%   M=MPLAY(...) returns a MoviePlayerAPI object, M, useful for
%   programmatic control of the movie player GUI.  A list of
%   all available object methods is obtained from "methods(M)".
%
%   Movie formats
%   -------------
%   Movie A may be one of the following formats:
%
%   Standard MATLAB movie structure (FMT = 'structure' or 'S')
%     See 'help getframe' for more information on the MATLAB
%     movie structure.  Only movies with empty .colormap field
%     entries are supported.
%    
%   Intensity video array (FMT = 'intensity' or 'I')
%     3-D array organized as MxNxF, where each image is of size
%     MxN and there are F image frames.  An input with size
%     exactly MxNx3 will be interpreted as a 3-frame intensity movie.
%
%   RGB video array (FMT = 'RGB')
%     4-D array organized as MxNx3xF, where the R, G, and B
%     are encoded in the 3rd dimension.  Note that MxNx3 is
%     the usual MATLAB format for an RGB image.
%
%   Video frame data type may be double, uint8, or uint16.
%
%   Keyboard support
%   ----------------
%   P:Play  F:FFwd  Rt:StepFwd  Up:First  J:Jump  X:FwdBkwd
%   S:Stop  R:Rew   Lt:StepRev  Dn:Last   L:Loop
%
%   EXAMPLE: Playback of standard MATLAB movies.
%      Run 'crulspin' or 'logospin' from the command line.
%      These demos create a MATLAB movie structure in the
%      workspace in variable 'm'.  Run "mplay(m)" and be
%      sure to turn on looping playback.
%
% See also MOVIE, INT2RGBM, INT2STRUCT, STRUCT2RGBM, IMVIEW.

% Copyright 2003 The MathWorks, Inc.
% Author: D. Orofino
% $Revision: 1.3 $ $Date: 2005/03/31 00:39:48 $


% To do:
% ------
% - icon for export-to-imview
% - API properties: colormap
% - Interactive zoom

% Note: The following input syntax has been disabled in the
%       CheckMovieFormat() function.
%
%   Color video components (FMT = @user_fcn)
%     Cell array containing arrays reprsenting each color plane of a movie,
%     arranged in a form suitable for a pre-defined conversion function.
%     In this case, FMT specifies a function (string or function handle) that
%     converts from the color components to the 4-D RGB video format.  The
%     function is invoked as: RGBM = user_fcn(A{:}).  The function must
%     return a 4-D RGB movie array.  If omitted, FMT defaults to @int2rgbm.
%
%     Examples:
%          MPLAY({R,G,B},@int2rgbm)    % converts RGB components to 4-D array
%          MPLAY({R,G,B},10)           % uses int2rgbm by format, 10 frames/sec
%          MPLAY({Y,U,V},@yuv2rgbm,24) % 24 frames/sec, YUV data format
%


% GUI Data organization
% ---------------------
% Figure UserData
%   .hfig           handle to figure window
%   .haxis          handle to axis containing image object
%   .himage         handle to image object
%   .htoolbar       handle to GUI button toolbar
%   .htimer         timer object associated with this player
%   .hStatusBar     structure of handles to parts of status bar
%   .loopmode       0=no looping, 1=looping
%   .fbmode         0=no fwd/bkwd playback, 1=fwd/bkwd playback
%   .fbrev          1=currently in reverse-playback, only if fwd/bkwd flag true
%   .paused         true/false flag indicating that we're in
%                   pause mode --- set to false by pressing play or stop
%   .nextframe      next frame number to display
%   .currframe      current frame displayed in viewer
%   .jumpto_frame   frame number to jump to for frame num edit
%   .fps            requested frame rate (frames per second)
%   .varName        name of variable passed in to player
%   .numFrames      number of frames in movie
%   .frameRows      number of rows in movie image
%   .frameCols      number of columns in movie image
%   .cmapexpr       colormap expr to use during movie playback
%   .cmap
%   .UpdateImageFcn function pointer to image update fcn
%   .Movie          movie pixel data
%   .MovieFormat    'S'    Standard movie structure
%                   'I'    MxNxF
%                   'RGB'  MxNx3xF
%
% Timer Object UserData
%   .hfig         handle to corresponding figure window

try,
    % dfmt: desired movie format, as specified by user
    [A,dfmt,fps,msg] = parse_inputs(varargin{:});
    error(msg);
    
    % fmt: actual movie format to use,
    %      string normalized to proper spelling, capitalization, etc
    [A, fmt] = CheckMovieFormat(A, dfmt);

    % Create and load GUI with movie
    hfig = CreateGUI;
    LoadMovie(hfig, A, fmt, inputname(1), fps);
    UpdateGUIControls(hfig);
    AdjustPlayerSize(hfig);

    % Return object is LHS requested
    if nargout>0, mov=GetMoviePlayerAPI(hfig); end
    
    % Clean up
    set(hfig,'vis','on');  % time to show the player
    
catch,
    rethrow(lasterror);
end

% --------------------------------------------------------
function AdjustPlayerSize(hfig)
% Adjust width of player window to be no narrower than
% the extent needed to render the button and status bar
%
% Also, make sure it is no bigger than screen size

min_width = 370; % min pixel width to render toolbar
set(hfig,'units','pix');
figpos = get(hfig,'pos');

% Widen player to minimum width (if movie is very narrow)
if figpos(3) < min_width,
    figpos(3) = min_width;
end

% Shrink movie to screen as needed:
set(0,'units','pix');
screenpos = get(0,'screensize');
if figpos(3) > screenpos(3),
   figpos(3) = screenpos(3);
end
if figpos(4) > screenpos(4),
   figpos(4) = screenpos(4);
end

set(hfig,'pos',figpos);

% --------------------------------------------------------
function mov = GetMoviePlayerAPI(hfig)

fcn.ffwd       = @cb_ffwd;
fcn.goto_end   = @cb_goto_end;
fcn.goto_start = @cb_goto_start;
fcn.jumpto     = @cb_jumpto;
fcn.loop       = @cb_loop;
fcn.fbmode     = @cb_fbmode;
fcn.play       = @cb_play;
fcn.rewind     = @cb_rewind;
fcn.step_back  = @cb_step_back;
fcn.step_fwd   = @cb_step_fwd;
fcn.stop       = @cb_stop;
fcn.truesize   = @cb_truesize;
fcn.setfps     = @ext_setFPS;
fcn.getfps     = @ext_getFPS;
mov = mmovie.player(hfig,fcn);

% --------------------------------------------------------
function [A,fmt,fps,msg] = parse_inputs(varargin)
%PARSE_INPUTS Parse input arguments
%   Valid calling syntax:
%     MPLAY(A)
%     MPLAY(A, FMT)
%     MPLAY(A, FPS)
%     MPLAY(A, FMT, FPS)
% 
%  Defaults:
A=[];
fmt='';   % no format specified
fps=30;   % 30 frames per second
msg='';   % no errors

% Check number of input args
msg = nargchk(1,3,nargin);
if ~isempty(msg), return; end

A = varargin{1};

if nargin > 2,
    % 3 or more inputs
    fmt = varargin{2};
    fps = varargin{3};
    
elseif nargin==2
    % 2 inputs
    if ischar(varargin{2}),
        fmt = varargin{2};
    else
        % must disambiguate:
        %   (A,@my_func) from (A,fps)
        if isnumeric(varargin{2}),
            fps = varargin{2};
        else
            fmt = varargin{2};
        end
    end
end

% Check and expand FMT
%   Expand the desired format string specified by user
%   Make it lower case, and complete any partial string specified.
%
%   NOTE: If A is a cell-array, skip this
%         FMT could be a conversion function
%
if ~iscell(A),
    if ~isempty(fmt),
        if ~ischar(fmt),
            msg = 'FMT must be a string.';
            return
        end
        all_in={'intensity','rgb','structure'};  % user format strings
        all_out={'I','RGB','S'};                 % internal format strings
        i=strmatch(lower(fmt), all_in);
        if isempty(i),
            msg='Unrecognized FMT string specified.';
            return
        end
        fmt=all_out{i};
    end
end

% Check FPS
if ~isa(fps,'double') || numel(fps)~=1 || fps<=0,
    msg='FPS must be a scalar double-precision value > 0.';
    return
end

% --------------------------------------------------------
function [A,fmt,msg] = CheckMovieFormat(A,dfmt)
% DetermineMovieFormat

% Rules to disambiguate inputs when no format is specified
%
% Is input a structure?
%     - 'struct' assumed
%          check for .colormap and .cdata present
%          check for empty .colormap entries
%          check for MxN or MxNx3 sizes in each frame
%     - otherwise, ERROR
%
% Is input numeric?
%   - if not, ERROR
%
% Is input 4-D?
%   Are both the 1st and 3rd dims ~= 3 (or empty)?
%      ERROR
%   Are both the 1st and 3rd dims == 3?
%      - assume 'rgb'
%      - WARN user of ambiguity, and to pass 'rgb' format string
%        to suppress warning next time
%   Is the 1st dim = 3 and the 3rd dim ~= 3?
%      - 'rgbp' assumed
%   Is the 1st dim ~= 3 and the 3rd dim = 3?
%      - 'rgb' assumed
%
% Is input 3-D?
%   Is the 3rd dim = 3?
%       WARN that this is being interpreted as a 3-frame intensity movie,
%       and to pass 'intensity' format string to suppress warning next time
%
% Is input 2-D?
%    - 'intensity' assumed, one frame
%
% Otherwise, ERROR

fmt = '';  % default
CR = sprintf('\n');

% Check for movie structure format
%
if isstruct(A),
    fmt = 'S';
    if ~isempty(dfmt) && ~strcmp(fmt,dfmt),
        error('Movie format (%s) doesn''t match specified format (%s)',fmt,dfmt);
    end
    
    % Check for required fields
    if ~isfield(A, 'colormap') || ~isfield(A, 'cdata'),
        error('Invalid movie: structure format does not contain required fields.');
    end
    
    % Check for empty colormap fields and movie datatypes
    %  - check all frames (thorough but time consuming)
    %  - check just the first frame (quick but incomplete)
    %
    i=1;                 % just check first frame
    %for i=1:length(A),  % check all entries in structure
        if ~isempty(A(i).colormap),
            error('All colormap fields in structure format must be empty.');
        end
        c=class(A(i).cdata);
        switch c,
            case {'uint8','double'},
            otherwise,
                error('Unsupported data type (%s) found in video frames.', c);
        end
    %end
    return
end

% Check for cell-array arguments
%
% NOTE: Disabled color conversion syntax
if 0,
if iscell(A),
    % Convert cell array of color components to 4-D RGB video array
    % using user-defined conversion function
    
    % Default if no conversion function specified: int2rgbm
    if isempty(dfmt),
        fmt = @int2rgbm;
    else
        fmt = dfmt;
    end
    
    % Try to invoke conversion function
    A = feval(fmt, A{:});
    
    % After the conversion, it is assumed that the video format is RGB
    fmt  = 'RGB';
    dfmt = 'RGB';
    
    % Fall-through to standard checking-code for N-D array
    % after conversion function has completed
end
end

if ~isnumeric(A),
    error('Unrecognized movie format.');
end

% Check for 3-D and 4-D RGB array formats
%
nd = ndims(A);
sz = size(A);
if nd==4,
    A33 = (sz(3)==3);
    if ~A33,
        error('Invalid movie format: 3rd dimension of array must be 3.');
    end
    fmt = 'RGB';
    if ~isempty(dfmt) && ~strcmp(fmt,dfmt),
        error('Movie format (%s) doesn''t match specified format (%s)',fmt,dfmt);
    end
    return
elseif nd==3,
    A33 = (sz(3)==3);
    if A33 && isempty(dfmt),
        warning(['Ambiguous movie format: 3rd dimension of 3-D array is 3.' CR ...
                 'Assuming ''intensity'' format.  Pass format string to suppress warning.']);
    end
    fmt='I';
    if ~isempty(dfmt) && ~strcmp(fmt,dfmt),
        error('Movie format (%s) doesn''t match specified format (%s)',fmt,dfmt);
    end
    return
else  % 2-D input
    fmt='I';
    if ~isempty(dfmt) && ~strcmp(fmt,dfmt),
        error('Movie format (%s) doesn''t match specified format (%s)',fmt,dfmt);
    end
    return
end

% --------------------------------------------------------
function hfig = CreateGUI

% Determine renderer mode
if 0 & opengl('info'),
    renderer='opengl';
else
    renderer='painters';
end

% Create figure
defaultPos = [.4 .4 .3 .3]; %[50 50 400 400];
hfig = figure(...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'Renderer',renderer, ...
    'HandleVis','callback', ...
    'IntegerHandle','off', ...
    'KeyPressFcn',  @KeypressFcn, ...
    'Visible','off', ...
    'CloseRequestFcn',@DeleteFcn, ...
    'DeleteFcn',@DeleteFcn, ...
    'Units','Normalized',...
    'Position',defaultPos, ...
    'BackingStore','off', ...
    'DoubleBuffer','off');

% Setup movie area
defaultN = 64;
haxis = axes( ...
    'parent',hfig, ...
    'pos',[0 0 1 1], ...
    'vis','off', ...
    'xlim',[1 defaultN], ...
    'ylim', [1 defaultN], ...
    'ydir','reverse', ...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual',...
    'layer','bottom',...
    'nextplot','add', ...
    'dataaspectratio',[1 1 1], ...
    'drawmode','fast');
himage = image(...
    'parent',haxis, ...
    'cdata',zeros(defaultN), ...
    'xdata',1:defaultN, ...
    'ydata',1:defaultN, ...
    'erase','none');

% Setup default figure data
%
ud = get(hfig,'userdata');
ud.hfig        = hfig;
ud.haxis       = haxis;
ud.himage      = himage;
ud.htoolbar    = CreateButtonBar(hfig);
ud.htimer      = [];
ud.hStatusBar  = AddStatusBar(hfig);
ud.loopmode    = 0;  % non-looping
ud.fbmode      = 0;  % no fwd/bkwd playback
ud.fbrev       = 0;  % not in rev-playback
ud.paused      = 0;
ud.nextframe   = 1;
ud.currframe   = 0;
ud.jumpto_frame = 1;
ud.fps         = 0;   % frames per second
ud.varName     = '';  % variable name passed to player
ud.numFrames   = 0;
ud.frameRows   = 0;
ud.frameCols   = 0;
ud.cmapexpr    = 'gray(256)';  % default
ud.cmap        = gray(256);  % default
ud.UpdateImageFcn = [];
ud.Movie       = [];
ud.MovieFormat = '';
set(hfig,'userdata', ud);

% Finishing touches:
%  - show GUI
%  - enable resize fcn
set(hfig, ...
    'colormap', ud.cmap, ...
    'resizefcn', @ResizeFcn);

% -------------------------------------------------------------------------
function KeypressFcn(hcb, eventStruct)
% Handle keypresses in main window

hfig = gcbf;
key = get(hfig, 'CurrentChar');
if ~isempty(key), % unix keyboard has an empty key
    switch lower(key)
        case char(29) % right
            cb_step_fwd(hfig,[]);
        case char(28) % left
            cb_step_back(hfig,[]);
        case 'f'
            cb_ffwd(hfig,[]);
        case 'r'
            cb_rewind(hfig,[]);
            
        case 's'
            cb_stop(hfig,[]);
        case 'p'
            cb_play(hfig,[]);  % play/pause
        case char(30) % up
            cb_goto_start(hfig,[]);
        case char(31)  % down
            cb_goto_end(hfig,[]);
            
        case 'j' % jump to
            EditFrameNum(hfig);
        case 'l' % loop
            cb_loop(hfig,[]);
        case 'x' % fwd/bkwd playback
            cb_fbmode(hfig,[]);
            
        case char(13) % Enter
            % Open parameters dialog
            EditProperties(hfig);
    end
end

% --------------------------------------------------------
function DeleteFcn(hcb, eventStruct)
% How to get here:
%    Close all force
%    delete(h)
hfig=gcbf;
ud = get(hfig,'userdata');
if ~isempty(ud),
    stop(ud.htimer); % Shut off timer if running
end
delete(hfig);    % Close window

% --------------------------------------------------------
function ResizeFcn(hcb, eventStruct)

fd = get(hcb,'UserData');  % hcb = hfig
hAll  = fd.hStatusBar.All;

% Get positions and compute resize offsets:
fig_pos   = get(hcb,'pos');
frame_pos = get(fd.hStatusBar.Region,'pos');
frame_rt  = frame_pos(1)+frame_pos(3)-2;
delta = fig_pos(3)-frame_rt;

% Adjust positions:
for i=1:length(hAll),
    pos = get(hAll(i),'pos');
    pos(1) = pos(1) + delta;
    set(hAll(i),'pos',pos);
end

% Separately adjust hStatusBar.Region
% Grow it wider, don't move it:
pos = frame_pos;
pos(3)=pos(3)+delta;
set(fd.hStatusBar.Region,'pos',pos);

% --------------------------------------------------------
function hStatusBar = AddStatusBar(hfig)

hfig_pos = get(hfig,'pos');
CR = sprintf('\n');

% Status region frame
bg = [1 1 1]*.8;
pos=[0 0 hfig_pos(3)+2 22];
hStatusBar.Region = uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos, ...
    'backgr', bg, ...
    'foregr', [1 1 1]);

% Render right after background frame, so when resizing occurs,
% this will be "overwritten" by other data
hStatusBar.StatusText = uicontrol('parent',hfig, ...
    'style','text', ...
    'units','pix', ...
    'pos',[2 1 100 16], ...
    'string','Ready', ...
    'horiz','left', ...
    'backgr',bg, ...
    'foregr','k');

% Indents for display/trace timing
pos1 = [pos(3)-64 1 60 17];
[hStatusBar.FPS, hAll1] = makeStatusBarIndent(hfig,bg,pos1);
set(hStatusBar.FPS,'string','FPS: 0', ...
    'tooltip' ,['Frames Per Second']);
set(hAll1,'ButtonDownFcn',@cb_properties);

pos2 = [pos(3)-128 1 60 17];
[hStatusBar.FrameNum, hAll2] = makeStatusBarIndent(hfig,bg,pos2);
set(hStatusBar.FrameNum,'string','0:0', ...
    'tooltip', ['Current Frame : Total Frames']);
set(hAll2,'ButtonDownFcn',@cb_jumpto);

pos2 = [pos(3)-148-74 1 90 17];
[hStatusBar.FrameSize, hAll3] = makeStatusBarIndent(hfig,bg,pos2);
set(hStatusBar.FrameSize,'string','(FrameSize)', ...
    'tooltip', '(framesize readout)');
% set(hAll3,'ButtonDownFcn',@cb_properties);

% Group all status bar widget handles together, for resizing:
hStatusBar.All = [hAll1 hAll2 hAll3];

% -------------------------------------------------------------------------
function [h, hall] = makeStatusBarIndent(hfig,bg,pos1)
hall(1)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos1, ...
    'backgr', bg, ...
    'foregr', [1 1 1]*.4);

pos2=pos1;
pos2(4)=1;
hall(2)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos2, ...
    'backgr', [1 1 1], ...
    'foregr', [1 1 1]);
pos2=[pos1(1)+pos1(3)-1 pos1(2) 1 pos1(4)];
hall(3)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos2, ...
    'backgr', [1 1 1], ...
    'foregr', [1 1 1]);

hall(4) = uicontrol('parent',hfig, ...
    'style','text', ...
    'units','pix', ...
    'horiz','left', ...
    'fontweight','light', ...
    'fontsize',8, ...
    'pos',pos1+[2 2 -3 -3], ...
    'string', 'test', ...
    'backgr', bg, ...
    'foregr', [0 0 0]);
h=hall(4);  % main text widget

% -------------------------------------------------------------------------
function UpdateStandardStatusText(hfig)
% Setup some status bar text, indicating
% current scope state
%
ud = get(hfig,'userdata');
isRunning = strcmp(get(ud.htimer,'Running'),'on');
isPaused  = ~isRunning &  ud.paused;
isStopped = ~isRunning & ~ud.paused;

if isStopped,     str = 'Stopped';
elseif isPaused,  str = 'Paused';
else              str = 'Playing';
end

UpdateStatusText(hfig,str);

% -------------------------------------------------------------------------
function UpdateStatusText(hfig,str)
% Set arbitrary text into status region

if isempty(hfig), return; end
fd = get(hfig,'UserData');
set(fd.hStatusBar.StatusText,'string',str);

% --------------------------------------------------------
function UpdateGUIControls(hfig)
% Update GUI state, including:
%   - button enable states/icons
%   - status bar text

UpdateButtonEnables(hfig);
UpdateStandardStatusText(hfig);


% --------------------------------------------------------
function UpdateButtonEnables(hfig)
% Button states:
%   Enabled=1
%   Disabled=0
%             stopped  paused running 
%       Props          (all 1)
%       Truesz         (all 1)
%       Export         (all 1)
%
%       1st            (all 1)
%       Rew            (all 1)
%       StepRev  1        1      0
%       Stop     0        1      1
%       Play     1        1      1
%       StepFwd  1        1      0
%       FFwd           (all 1)
%       Last           (all 1)
%
%       JumpTo
%       Loop
%       Fwd/Bkwd Play

ud = get(hfig,'userdata');
isRunning = strcmp(get(ud.htimer,'Running'),'on');
isPaused  = ~isRunning &&  ud.paused;
isStopped = ~isRunning && ~ud.paused;

if     isStopped, ena = [1 0 1 1];
elseif isPaused,  ena = [1 1 1 1];
else              ena = [0 1 1 0];
end

hchild = flipud(get(ud.htoolbar,'children'));
for i=1:4,
    if ena(i), s='on'; else s='off'; end
    set(hchild(5+i),'enable',s);
end

% --------------------------------------------------------
function htoolbar = CreateButtonBar(hfig)
% Create button bar

% Get a bunch of playback-related icons
icons    = mergefields(load('audiotoolbaricons'), load('mplay_icons'));
CR       = sprintf('\n');
htoolbar = uitoolbar(hfig);         % Create toolbar
setappdata(htoolbar,'icons',icons); % Store icons in toolbar appdata

uipushtool(htoolbar, ...
    'cdata', icons.params, ...
    'tooltip','Properties...', ...
    'click', @cb_properties);
uipushtool(htoolbar, ...
    'cdata', icons.fit_to_view, ...
    'tooltip','True size', ...
    'click', @cb_truesize);
hexp=uipushtool(htoolbar, ...
    'cdata', icons.export_imview, ...
    'tooltip','Export to IMVIEW', ...
    'click', @cb_export_imview);

% Check for IMVIEW
if ~exist('imview','file'),
    % set(hexp,'enable','off');
    set(hexp,'tooltip', 'Export to Workspace');
end

uipushtool(htoolbar, ...
    'cdata', icons.goto_start_default, ...
    'tooltip','Go to start', ...
    'separator','on', ...
    'click', @cb_goto_start);
uipushtool(htoolbar, ...
    'cdata', icons.rewind_default, ...
    'tooltip','Rewind', ...
    'click', @cb_rewind);
uipushtool(htoolbar, ...
    'cdata', icons.step_back, ...
    'tooltip','Step back', ...
    'click', @cb_step_back);
uipushtool(htoolbar, ...
    'cdata', icons.stop_default, ...
    'tooltip','Stop', ...
    'click', @cb_stop);
uipushtool(htoolbar, ...
    'cdata', icons.play_on, ...
    'tooltip','Play', ...
    'tag','Play/Pause', ...
    'click', @cb_play);
uipushtool(htoolbar, ...
    'cdata', icons.step_fwd, ...
    'tooltip','Step forward', ...
    'click', @cb_step_fwd);
uipushtool(htoolbar, ...
    'cdata', icons.ffwd_default, ...
    'tooltip','Fast forward', ...
    'click', @cb_ffwd);
uipushtool(htoolbar, ...
    'cdata', icons.goto_end_default, ...
    'tooltip','Go to end', ...
    'click', @cb_goto_end);

uipushtool(htoolbar, ...
    'cdata', icons.jump_to, ...
    'separator','on', ...
    'tooltip','Jump to...', ...
    'click', @cb_jumpto);
uipushtool(htoolbar, ...
    'cdata', icons.loop_off, ...
    'tooltip',['Repeat playback'], ...
    'tag','loopbutton', ...
    'click', @cb_loop);
uipushtool(htoolbar, ...
    'cdata', icons.fwdbk_play_off, ...
    'tooltip',['<default>'], ...
    'tag','fbbutton', ...
    'click', @cb_fbmode);

% --------------------------------------------------------
function icons = get_icons_from_fig(hfig)

udfig = get(hfig,'userdata');
udtb = getappdata(udfig.htoolbar);
icons = udtb.icons;

% --------------------------------------------------------
function cb_goto_start(hbutton, eventStruct, hfig)
% goto start button callback
% jump to frame 1, cancel bkwd playback (if on)

if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
if ud.currframe ~= 1,  % prevent repeated presses
    ud.currframe = 1;
    ud.nextframe = 1;
    ud.fbrev     = 0;  % cancel any bkwd playback
    set(hfig,'userdata',ud);
    ShowMovieFrame(hfig);
end

% --------------------------------------------------------
function cb_rewind(hbutton, eventStruct, hfig)
% Rewind button callback
% Backup "stepsize" frames
if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
stepsize = 10;

if ud.fbmode,
    % fwd/back playback mode
    if ud.fbrev,
        % in reverse ... increment
        if ud.currframe >= ud.numFrames-stepsize,
            % hit last frame ... go to reverse
            ud.currframe = ud.numFrames;
            ud.fbrev=0;  % no more reverse playback
        else
            ud.currframe = ud.currframe+stepsize;
        end
    else
        % not in reverse ... decrement
        if ud.currframe <= stepsize,
            ud.fbrev=1;  % hit reverse playback
            ud.currframe = stepsize+1;  % so next subtraction brings us to frame 1
        end
        ud.currframe = ud.currframe-stepsize;
    end
else
    % Not fwd/back mode    
    
    ud.currframe = ud.currframe - stepsize;
    % Check for backwards wraparound
    if ud.currframe < 1,
        if ~ud.loopmode,
            if ud.currframe == 1-stepsize,
                return
            end
            ud.currframe = 1;
        else
            ud.currframe = ud.currframe+ud.numFrames;
        end
    end
end

% Store for next time:
ud.nextframe = ud.currframe;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(hfig,'userdata',ud);
ShowMovieFrame(hfig);
if upd, UpdateGUIControls(hfig); end

% --------------------------------------------------------
function cb_play(hbutton, eventStruct, hfig)
% Play button callback

if nargin<3, hfig  = gcbf; end

ud    = get(hfig,'userdata');
icons = get_icons_from_fig(hfig);
hPlay = findobj(ud.htoolbar, 'tag','Play/Pause');

% Check if timer is already running
if strcmp(get(ud.htimer,'Running'),'on'),
    % Movie already playing
    %  - Move to Pause mode
    %  - Show Play icon (currently must be pause indicator)
    
    % Stop timer, set pause mode
    ud.paused = 1;
    set(hfig,'userdata',ud);
    stop(ud.htimer);
    
    % Flush changes
    ShowMovieFrame(hfig);
    %UpdateFrameReadout(ud);

    % Set play icon, darker
    set(hPlay, ...
        'tooltip', 'Resume', ...
        'cdata', icons.play_off);
else
    % Not running
    if ud.paused,
        % Paused - move to play
        ud.nextframe = ud.currframe;
    else
        % Stopped - move to play
        ud.nextframe = 1;  % Start from 1st frame when stopped
        ud.fbrev     = 0;  % Reset fwd/bkwd state to fwd
    end
    set(hfig,'userdata',ud);
    
    % Show pause icon
    set(hPlay, ...
        'tooltip', 'Pause', ...
        'cdata', icons.pause_default);
    start(ud.htimer);
end
UpdateGUIControls(hfig);

% --------------------------------------------------------
function cb_stop(hbutton, eventStruct, hfig)
% Stop button callback

if nargin<3, hfig  = gcbf; end

ud = get(hfig,'userdata');
ud.paused = 0;  % we're stopped, not paused
set(hfig,'userdata',ud);

isRunning = strcmp(get(ud.htimer,'Running'),'on');
if isRunning,
    stop(ud.htimer);
else
    % Allow stop even when movie not running
    % We could have been paused
    do_timer_stop(hfig);
end

% --------------------------------------------------------
function cb_step_back(hbutton, eventStruct, hfig)
% Step one frame backward callback

if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');

if ud.fbmode,
    % fwd/back playback mode
    if ud.fbrev,
        % in reverse ... increment
        if ud.currframe == ud.numFrames-1,
            % will hit last frame ... go to normal playback
            ud.fbrev=0;  % normal playback
        end
        ud.currframe = ud.currframe+1;
    else
        % not in reverse ... decrement
        if ud.currframe == 1,
            % fwd/back hit when frame 2 displayed
            %   move to frame 1 in non-reverse mode, then go to reverse
            %   mode
            ud.fbrev=1;  % enter reverse playback
            ud.currframe = 2;
        else
            ud.currframe = ud.currframe-1;
        end
    end
else
    % Not fwd/back mode    
    if ud.currframe <= 1,
        if ~ud.loopmode,
            return
        end
        ud.currframe = ud.numFrames;
    else
        ud.currframe = ud.currframe-1;
    end
end

ud.nextframe = ud.currframe;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(hfig,'userdata',ud);
ShowMovieFrame(hfig);
if upd, UpdateGUIControls(hfig); end

% --------------------------------------------------------
function cb_step_fwd(hbutton, eventStruct, hfig)
% Step one frame forward callback

% If in fwdbk mode,
%   Ignore looping mode
%   We always go from fwd to bkwd when step_fwd pressed at last frame
%   When we're at frame 1, we must continue to frame 2 regardless of the
%   looping setting since we don't know "how" we got there

if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');

if ud.fbmode,
    % fwd/back playback mode
    if ~ud.fbrev,
        % not in reverse ... increment fwd
        if ud.currframe >= ud.numFrames,
            % hit last frame ... go to reverse
            ud.currframe = ud.currframe-1;
            ud.fbrev=1;  % reverse playback
        else
            ud.currframe = ud.currframe+1;
        end
    else
        % in reverse ... decrement
        if ud.currframe == 2,
            % fwd/back hit when frame 2 displayed
            %   move to frame 1 in reverse mode
            ud.fbrev=0;  % no more reverse playback
        end
        ud.currframe = ud.currframe-1;
    end
else
    % Not fwd/back mode    
    if ud.currframe >= ud.numFrames,
        if ~ud.loopmode,
            return
        end
        ud.currframe = 1;
    else
        ud.currframe = ud.currframe+1;
    end
end

ud.nextframe = ud.currframe;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(hfig,'userdata',ud);
ShowMovieFrame(hfig);
if upd, UpdateGUIControls(hfig); end

% --------------------------------------------------------
function cb_ffwd(hbutton, eventStruct, hfig)
% Fast forward button callback
if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
stepsize = 10;

if ud.fbmode,
    % In fwd/rev playback mode
    if ~ud.fbrev,
        % not in reverse ... increment fwd
        if ud.currframe >= ud.numFrames-stepsize,
            % hit last frame ... go to reverse
            ud.currframe = ud.numFrames;
            ud.fbrev=1;  % reverse playback
        else
            ud.currframe = ud.currframe+stepsize;
        end
    else
        % in reverse mode
        if ud.currframe <= stepsize,
            ud.fbrev=0;  % no more reverse playback
            ud.currframe = stepsize+1;  % so next subtraction brings us to frame 1
        end
        ud.currframe = ud.currframe-stepsize;
    end
else
    % Not in fwd/rev playback mode
    ud.currframe = ud.currframe + stepsize;
    if ud.currframe > ud.numFrames,
        if ~ud.loopmode,
            if ud.currframe == ud.numFrames+stepsize,
                return
            end
            ud.currframe = ud.numFrames;
        else
            ud.currframe = ud.currframe-ud.numFrames;
        end
    end
end

ud.nextframe = ud.currframe;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(hfig,'userdata',ud);
ShowMovieFrame(hfig);
if upd, UpdateGUIControls(hfig); end

% --------------------------------------------------------
function cb_goto_end(hbutton, eventStruct, hfig)
% Goto end button callback
%
% NOTE: For fwd/bkwd mode, goes to last frame as usual,
% and enters bkwd playback.  No special code needed.

if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
if ud.currframe ~= ud.numFrames,
    ud.currframe = ud.numFrames;
    ud.nextframe = ud.currframe;
    set(hfig,'userdata',ud);
    ShowMovieFrame(hfig);
end

% --------------------------------------------------------
function cb_loop(hbutton, eventStruct, hfig)
% Loop button callback
% Store loopmode state
if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
ud.loopmode = ~ud.loopmode;
set(hfig,'userdata',ud);

ReactToStoredLoopMode(hfig);


% --------------------------------------------------------
function cb_fbmode(hbutton, eventStruct, hfig)
% Fwd/Bkwd playback button callback
% Store state
if nargin<3, hfig  = gcbf; end
ud = get(hfig,'userdata');
ud.fbmode = ~ud.fbmode;
ud.fbrev  = 0; % Reset direction when fb status changes
set(hfig,'userdata',ud);

ReactToStoredFBMode(hfig);

% --------------------------------------------------------
function cb_truesize(hco, eventStruct, hfig)

if nargin<3, hfig=gcbf; end
SetupMovieFrame(hfig);

% --------------------------------------------------------
function ReactToStoredLoopMode(hfig)

icons = get_icons_from_fig(hfig);
ud = get(hfig,'userdata');
if ud.loopmode,
    icon = icons.loop_on;
    tip = 'Repeat: On';
else
    icon = icons.loop_off;
    tip = 'Repeat: Off';
end
hLoopButton = findobj(hfig,'tag','loopbutton');
set(hLoopButton,'cdata',icon,'tooltip',tip);

% --------------------------------------------------------
function ReactToStoredFBMode(hfig)

% Update button icon/tip
icons = get_icons_from_fig(hfig);
ud = get(hfig,'userdata');
if ud.fbmode,
    icon = icons.fwdbk_play_on;
    tip = 'Forward/backward playback';
else
    icon = icons.fwdbk_play_off;
    tip = 'Normal playback';
end
hFBButton = findobj(hfig,'tag','fbbutton');
set(hFBButton,'cdata',icon,'tooltip',tip);

% Update frame readout and tooltip
UpdateFrameReadout(ud);
UpdateFrameReadoutTooltip(ud);

% --------------------------------------------------------
function [r,c,f] = MovieSizeInfo(A, fmt)
% Determine rows, columns, and frames for each movie format
%                 'S'    Standard Movie structure
%                 'I'    MxNxF
%                 'RGB'  MxNx3xF

switch fmt
    case 'I'
        r=size(A,1);
        c=size(A,2);
        f=size(A,3);
    case 'RGB'
        r=size(A,1);
        c=size(A,2);
        f=size(A,4);
    case 'S'
        r=size(A(1).cdata,1);
        c=size(A(1).cdata,2);
        f=length(A);
end

% --------------------------------------------------------
function LoadMovie(hfig, A, fmt, varname, fps)

% Store basic movie info:
%
ud = get(hfig,'userdata');
ud.MovieFormat = fmt;
ud.Movie     = A;
ud.fps       = fps;
ud.varName   = varname;
[r,c,f]      = MovieSizeInfo(A,fmt);
ud.frameRows = r;
ud.frameCols = c;
ud.numFrames = f;
ud.currframe = 1;
ud.nextframe = 1;

% Store data, set name in figure title
set(hfig, ...
    'userdata', ud, ...
    'name', sprintf('Movie Player: %s', ud.varName));

% Update viewer
%
set(hfig,'name', sprintf('Movie Player: %s', ud.varName));
SetupUpdateFunction(hfig);    % Select playback function
SetupMovieFrame(hfig);        % Shrink figure to movie size
SetupTimer(hfig);             % Updates FPS status readout via SetFPS
ShowMovieFrame(hfig);         % Updates frame counter status readout
UpdateFrameSizeReadout(hfig); % Updates frame size readout
ReactToStoredLoopMode(hfig);  % Initial update of button icon
ReactToStoredFBMode(hfig);    % Initial update of button icon

% --------------------------------------------------------
function SetupMovieFrame(hfig)
% Sets up frame sizes, window sizes, etc
% Leaves existing image in display

ud = get(hfig,'userdata');
rows=ud.frameRows;
cols=ud.frameCols;

% Adjust image limits and axis limits appropriately
set(ud.himage,'xdata', 1:cols, 'ydata', 1:rows);
% Do a "truesize" like operation
set(ud.haxis, ...
    'xlim',[1 cols], ...
    'ylim',[1 rows], ...
    'units','pix', ...
    'pos',[1 1 cols rows]);

% Set figure to be an exact fit around the axis
set(ud.hfig,'units','pix');
figpos = get(ud.hfig,'pos');
newpos = [figpos(1:2) cols rows];
set(ud.hfig,'pos',newpos);

set(ud.haxis,'units','norm');  % allow stretching again


% --------------------------------------------------------
function ShowMovieFrame(hfig, fast)

% Update video image
ud = get(hfig,'userdata');
feval(ud.UpdateImageFcn, ud);

% Update frame counter
if (nargin > 1) && fast,
    if (ud.currframe==1) || (rem(ud.currframe,10)==0),
        UpdateFrameReadout(ud);
    end
else
    UpdateFrameReadout(ud);
end

% --------------------------------------------------------
function y = GetExportFrame(ud)
switch ud.MovieFormat
    case 'I'
        y = ud.Movie(:,:,ud.currframe);
    case 'RGB'
        y = ud.Movie(:,:,:,ud.currframe);
    case 'S'
        y = ud.Movie(ud.currframe).cdata;
    otherwise
        error('Unrecognized movie format.');
end

% --------------------------------------------------------
function UpdateIntensityImage(ud)
set(ud.himage,'cdata', ud.Movie(:,:,ud.currframe));

function UpdateRGBImage(ud)
set(ud.himage,'cdata', ud.Movie(:,:,:,ud.currframe));

function UpdateStructImage(ud)
set(ud.himage,'cdata', ud.Movie(ud.currframe).cdata);

% --------------------------------------------------------
function SetupUpdateFunction(hfig)
% Register image update function

ud = get(hfig,'userdata');
switch ud.MovieFormat
    case 'I'
        ud.UpdateImageFcn = @UpdateIntensityImage;
    case 'RGB'
        ud.UpdateImageFcn = @UpdateRGBImage;
    case 'S'
        ud.UpdateImageFcn = @UpdateStructImage;
    otherwise
        error('Unrecognized movie format.');
end
set(hfig,'userdata',ud);


% --------------------------------------------------------
function SetupTimer(hfig)

% Setup timer
h = timer( ...
    'ExecutionMode','fixedRate', ...
    'TimerFcn', @TimerTickFcn, ...
    'StopFcn', @TimerStopFcn, ...
    'BusyMode', 'drop', ...
    'TasksToExecute', inf);

% Store fig handle in timer
udtimer.hfig = hfig;
set(h,'userdata',udtimer);

% Store timer handle in figure
ud = get(hfig,'userdata');
ud.htimer = h;
set(hfig,'userdata', ud);

SetFPS(hfig);

% --------------------------------------------------------
function y = ext_getFPS(hfig)
ud = get(hfig,'userdata');
y = ud.fps;

% --------------------------------------------------------
function ext_setFPS(hfig, fps)

ud = get(hfig,'userdata');
ud.fps = fps;
set(hfig,'userdata',ud);
SetFPS(hfig);


% --------------------------------------------------------
function SetFPS(hfig)
% Set frames per second for playback

% Cannot change period while movie is running
% Must stop timer, change frame rate, then restart timer

ud = get(hfig,'userdata');
isRunning = strcmp(get(ud.htimer,'Running'),'on');
% isPaused = ud.paused;
if isRunning, 
    cb_play([],[],ud.hfig);  % pause
end
set(ud.htimer,'Period', 1./ud.fps);
if isRunning, 
    cb_play([],[],ud.hfig);
%     ud = get(hfig,'userdata');
%     ud.paused = isPaused;
%     set(hfig,'userdata',ud);
end
UpdateFPSReadout(hfig);

% -------------------------------------------------------------------------
function UpdateFrameSizeReadout(hfig)
% Update current frame size readout in status bar

ud         = get(hfig,'UserData');
sizeStr    = sprintf('%dx%d', ud.frameRows, ud.frameCols);
readoutStr = sprintf('%s:%s', ud.MovieFormat, sizeStr);

% Build tooltip for frame format/size status bar readout
switch ud.MovieFormat
    case 'I',   s='Intensity';
    case 'S',   s='Structure';
    case 'RGB', s='RGB';
end
CR = sprintf('\n');
tipStr = [s ' format' CR sprintf('%d rows x %d cols', ud.frameRows, ud.frameCols)];

set(ud.hStatusBar.FrameSize,'string',readoutStr,'tooltip',tipStr);

% -------------------------------------------------------------------------
function UpdateFrameReadout(ud)
% Update current frame number readout in status bar
% If fwd/bkwd mode not on,
%    show "current frame : total frames"
% If on,
%    show "+/- current frame : total frames"
%  where + means fwd play, - means bkwd play

str = sprintf('%d:%d',ud.currframe,ud.numFrames);
if ud.fbmode,
    if ud.fbrev,
        dir='-';
    else
        dir='+';
    end
    str = [dir str];
end
set(ud.hStatusBar.FrameNum, 'string', str);

% -------------------------------------------------------------------------
function UpdateFrameReadoutTooltip(ud)

tStr = 'Current Frame : Total Frames';
if ud.fbmode,
    tStr = [tStr sprintf('\n') '+: Fwd dir, -:Bkwd dir'];
end
set(ud.hStatusBar.FrameNum, 'tooltip', tStr);

% -------------------------------------------------------------------------
function UpdateFPSReadout(hfig)
% Update frames per second readout in status bar

ud = get(hfig,'UserData');
str = sprintf('FPS: %d',ud.fps);
set(ud.hStatusBar.FPS,'string',str);

% --------------------------------------------------------
function EditProperties(hfig)
% Get frames per second in dialog box

ud = get(hfig,'userdata');

while 1,  % infinite loop in case user enters invalid information
    % Get dialog
    prompt={'Desired playback rate (fps):', ...
            'Colormap expression:'};
    def={num2str(ud.fps), ud.cmapexpr};
    dlgTitle='Movie Player Properties';
    lineNo=1;
    AddOpts.Resize='off';
    AddOpts.WindowStyle='modal';
    AddOpts.Interpreter='none';
    answer=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    
    if ~isempty(answer),  % cancel pressed?
        % Error check
        
        % Frame rate:
        %
        new_fps = str2num(answer{1});
        if new_fps > 0,
            if ~isequal(new_fps, ud.fps),  % change made?
                % Grab userdata now in case changes were made
                %   while dialog was open
                ext_setFPS(hfig,new_fps);
            end
        else
            hwarn = warndlg({'Invalid frames/second entered.','Must be > 0.'}, 'Movie Player Error','modal');
            waitfor(hwarn);
            continue;
        end
        
        % Colormap:
        %
        new_cmapexpr = deblank(answer{2});
        new_cmap = eval(new_cmapexpr, '[]');
        if isempty(new_cmap),
            hwarn = warndlg('Invalid colormap expression.','Movie Player Error','modal');
            waitfor(hwarn);
            continue;
        else
            if ~isequal(new_cmapexpr, ud.cmapexpr),  % change made?
                % Grab userdata now in case changes were made
                %   while dialog was open
                ud = get(hfig,'userdata');
                ud.cmapexpr = new_cmapexpr;
                ud.cmap     = new_cmap;
                set(hfig, 'userdata',ud, 'colormap',new_cmap);
            end
        end
    end
    break  % stop infinite loop
end

% --------------------------------------------------------
function EditFrameNum(hfig)
% Get manually specified frame number in dialog box
% "Jump to" operation

% Initialize to last "jump to" value, NOT to the current frame
% This way, the edit operation becomes useful for continually
% jumping to a particular frame

ud = get(hfig,'userdata');

while 1,  % infinite loop in case user enters invalid information
    % Show dialog
    prompt   = {'Jump to frame:'};
    def      = {num2str(ud.jumpto_frame)};
    dlgTitle = 'Movie Player Properties';
    lineNo   = 1;
    AddOpts.Resize      = 'off';
    AddOpts.WindowStyle = 'normal';
    AddOpts.Interpreter = 'none';
    answer = inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    
    if ~isempty(answer),  % cancel pressed?
        % Error check
        
        % Currently Displayed Frame:
        %
        new_jumpto = str2num(answer{1});
        if (new_jumpto > 0) && (new_jumpto <= ud.numFrames),
            % Note: always perform update, even if value remains the same
            % That's because the currently displayed frame may have
            % changed behind our backs.  Even if we re-grab userdata,
            % it's changing all the time.
                
            % Get properties again, in case something has
            % changed behind our backs while dialog was open
            ud = get(hfig,'userdata');
            ud.currframe = new_jumpto;
            ud.nextframe = new_jumpto;
            ud.jumpto_frame = new_jumpto;
            
            % jump puts player in pause mode if currently stopped
            isRunning = strcmp(get(ud.htimer,'Running'),'on');
            isStopped = ~isRunning && ~ud.paused;
            ud.paused = 1;
            
            set(hfig,'userdata',ud);
            ShowMovieFrame(hfig);
            if isStopped, UpdateGUIControls(hfig); end
        else
            hwarn = warndlg({'Invalid frame number.'}, 'Movie Player Error','modal');
            waitfor(hwarn);
            continue
        end
    end
    break  % stop infinite loop
end

% --------------------------------------------------------
function cb_properties(hco, eventStruct)
EditProperties(gcbf);

function cb_jumpto(hco, eventStruct)
EditFrameNum(gcbf);

% --------------------------------------------------------
function cb_export_imview(hco, eventStruct)
% Export current image frame to IMVIEW or base workspace.

hfig = gcbf;
ud = get(hfig,'userdata');
v = GetExportFrame(ud);
if exist('imview','file'),
    try
        imview(v);
    catch
        warndlg(sprintf('Failed when calling IMVIEW:\n\n%s', lasterr), ...
            'MPLAY Export Error', 'modal');
    end
else
    % Export to workspace
    varname = 'mplay_export';
    fprintf(['Exported current image frame to base workspace\n' ...
            'Variable name: %s\n\n'], varname);
    assignin('base',varname,v);
end

% --------------------------------------------------------
function TimerTickFcn(hco, user)

ud = get(hco,'userdata');     % hco = timer object
hfig = ud.hfig;
ud = get(hfig,'userdata');
ud.currframe = ud.nextframe;
ShowMovieFrame(hfig, 1);  % "fast" display

% Increment frame or stop playback if finished
if (ud.currframe == ud.numFrames),
    % Last frame of movie just displayed
    
    if ud.fbmode % && ~ud.fbrev,  % unnecessary qualifier --- always will be false here
        ud.fbrev = 1;  % going into reverse playback mode
        ud.nextframe = ud.currframe-1;
        shouldStop = 0;
        
%     elseif ud.fbmode && ud.fbrev,
%         error('how did this happen? ==end');
%         shouldStop = 1;
        
    else
        ud.nextframe = 1;  % loop back to beginning
        shouldStop = 1;
    end
    
    % If we hit this point, the timer ran us to the end of
    % the movie.  In particular, the user did not hit stop.
    % Now, if pause is on, it's due to manual interaction with
    % the fwd/back buttons, and not due to actual pausing,
    % obvious since we're still running and is why we're here.
    % Turn off pause:
    ud.paused = 0;
    
elseif (ud.currframe == 1),
    % First frame of movie just displayed
    if ud.fbmode && ud.fbrev,
        ud.fbrev = 0;  % going into fwd playback mode
        ud.nextframe = ud.currframe+1;
        shouldStop = 1;
    else
        ud.nextframe = 2;  % ud.currframe+1
        shouldStop = 0;
    end
    
else
    if ud.fbmode && ud.fbrev,
        ud.nextframe = ud.nextframe - 1;  % next frame, reverse play
    else
        ud.nextframe = ud.nextframe + 1;  % next frame, fwd play
    end
    shouldStop = 0;
end
set(hfig,'userdata',ud);

if shouldStop && ~ud.loopmode, % no looping - stop now
    stop(ud.htimer); % stop playback
end

% --------------------------------------------------------
function TimerStopFcn(hco, user)
% Keep this here, not in cb_stop
% Could have stopped from stop button (eg, gone thru cb_stop)
% but also could have stopped here due to end of movie

ud = get(hco,'userdata');
do_timer_stop(ud.hfig);

% --------------------------------------------------------
function do_timer_stop(hfig)

ud = get(hfig,'userdata');
% ShowMovieFrame(hfig);
UpdateFrameReadout(ud);

% Set play icon, brighter
icons = get_icons_from_fig(hfig);
hPlay = findobj(ud.htoolbar, 'tag','Play/Pause');
set(hPlay, ...
    'tooltip', 'Play', ...
    'cdata', icons.play_on);
UpdateGUIControls(hfig);

% --------------------------------------------------------
function z = mergefields(varargin)
%MERGEFIELDS Merge fields into one structure
%   Z = MERGEFIELDS(A,B,C,...) merges all fields of input structures
%   into one structure Z.  If common field names exist across input
%   structures, values from later input arguments prevail.
%
%   Example:
%     x.one=1;  x.two=2;    % Define structures
%     y.two=-2; y.three=3;  % containing a common field (.two)
%     z=mergefields(x,y)  % => .one=1, .two=-2, .three=3
%     z=mergefields(y,x)  % => .one=1, .two=2,  .three=3
%
%   See also SETFIELD, GETFIELD, RMFIELD, ISFIELD, FIELDNAMES.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2005/03/31 00:39:48 $

z=varargin{1};
for i=2:nargin,
    f=fieldnames(varargin{i});
    for j=1:length(f),
        z.(f{j}) = varargin{i}.(f{j});
    end
end

% [EOF] mplay.m
