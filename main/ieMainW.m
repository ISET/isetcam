function varargout = ieMainW(varargin)
%IEMAINW M-file for ieMainW.fig
%      IEMAINW, by itself, creates a new IEMAINW or raises the existing
%      singleton*.
%
%      H = IEMAINW returns the handle to a new IEMAINW or the handle to
%      the existing singleton*.
%
%      IEMAINW('Property','Value',...) creates a new IEMAINW using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ieMainW_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IEMAINW('CALLBACK') and IEMAINW('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IEMAINW.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ieMainW

% Last Modified by GUIDE v2.5 29-Dec-2011 15:09:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ieMainW_OpeningFcn, ...
                   'gui_OutputFcn',  @ieMainW_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% varargin{1}

% --- Executes just before ieMainW is made visible.
function ieMainW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ieMainW
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ieMainW wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Choose default command line output for ieMainWindow
handles.output = hObject;

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(gcf,'Color',defaultBackground)

% Update handles structure
guidata(hObject, handles);

image(imread('mainIcon.jpg')); axis off; axis image;

ieSessionSet('mainwindow',hObject,eventdata,handles);

% If the person has set a position and size preference, put the window
% there
ISETprefs = getpref('ISET');
if isfield(ISETprefs,'wPos')
    wPos = ISETprefs.wPos;
    if ~isempty(wPos{1}), set(hObject,'Position',wPos{1}); end
end
refreshMain(handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = ieMainW_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;

% --- Executes on button press in btnScene.
function btnScene_Callback(hObject, eventdata, handles)
% Scene button
sceneWindow;
return;

% --- Executes on button press in btnOI.
function btnOI_Callback(hObject, eventdata, handles)
% Optics button
oiWindow;
return;

% --- Executes on button press in btnSensorImage.
function btnSensorImage_Callback(hObject, eventdata, handles)
% Sensor button
sensorWindow;
return;

% --- Executes on button press in btnProcessor.
function btnProcessor_Callback(hObject, eventdata, handles)
% Processor button
ipWindow;
return;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuInit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuHelpDocumentation_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('imageval code');
return

% --------------------------------------------------------------------
function menuHelpFunctions_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('iset functions');
return

% --------------------------------------------------------------------
function menuHelpImageval_Callback(hObject, eventdata, handles)
% Help | ImagEval (home)
ieManualViewer('imageval');
return

% --------------------------------------------------------------------
function menuInitLicenseStore_Callback(hObject, eventdata, handles)
% Initialize | Store license
ieLicenseStore;
return;

% --------------------------------------------------------------------
function menuInitKeyGet_Callback(hObject, eventdata, handles)
% Initialize | Get Key
ieKeyGet;
return


% --------------------------------------------------------------------
function menuInitKeyStore_Callback(hObject, eventdata, handles)
% Initialize | Store Key
ieKeyStore;
return;

% --------------------------------------------------------------------
function menuInitVerify_Callback(hObject, eventdata, handles)
% Initialize | Key Verify
val = ieKeyVerify;
if strcmp(val{1},md5([num2str(date),'1951'])),
    ieInWindowMessage('License/Key Verified',handles,5);
else
    ieInWindowMessage('License/Key Not Verified',handles,[]);
end
return

% --------------------------------------------------------------------
function menuInitVerifyMex_Callback(hObject, eventdata, handles)
% Init | Verify mex 
ieInstall
return;

% --------------------------------------------------------------------
function menuInitMicrosoftLib_Callback(hObject, eventdata, handles)
% Init | Verify mex 
ieInstall
return;

% --------------------------------------------------------------------
function menuLoadSession_Callback(hObject, eventdata, handles)
% File | Load session

sessionFileName = vcSelectDataFile('session','r','mat');
cmd = ['load ',sessionFileName]; eval(cmd); 
disp(iePrintSessionInfo);
refreshMain(handles);
return

% --------------------------------------------------------------------
function menuFileRename_Callback(hObject, eventdata, handles)
% File | Rename session

sessionName = ieReadString('Select session name');
if isempty(sessionName), return; end

[p,fname,e] = fileparts(sessionName);
if ~strcmp(e,'.mat'), e = '.mat'; fname = [fname,e]; end

ieSessionSet('sessionname',fname);
refreshMain(handles);
return


% --------------------------------------------------------------------
function menuFileFontSize_Callback(hObject, eventdata, handles)
% File | Font Size
% Change font size
ieFontSizeSet(handles.figure1);

% Keep the big ISET big despite changing the other text
set(handles.text1,'fontsize',32);
set(handles.txtISET,'fontsize',18);

refreshMain(handles);
return

% --------------------------------------------------------------------
function menuFileWaitBar_Callback(hObject, eventdata, handles)
% File | Waitbar
% Toggle state of waitbar

% h = guihandles;
b = ieSessionGet('wait bar');
if b
    ieSessionSet('wait bar',false);
else
    ieSessionSet('wait bar',true);
end
refreshMain(handles);
return

%
function menuFileRefresh_Callback(hObject, eventdata, handles)
% File | Refresh
refreshMain(handles);
return
% --------------------------------------------------------------------
function menuFileSave_Callback(hObject, eventdata, handles)
% File | Save
vcSaveSESSION;
return

% --------------------------------------------------------------------
function menuFileSaveAs_Callback(hObject, eventdata, handles)
% File | Save As
fullName = vcSelectDataFile('session','w','mat');
[sessionDir,fname] = fileparts(fullName);
ieSessionSet('sessionname',fname);
ieSessionSet('sessiondir',sessionDir);
vcSaveSESSION(fname);
refreshMain(handles);
return

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
% File | Close
ieMainClose;
return

% --------------------------------------------------------------------
function menuFileSaveClose_Callback(hObject, eventdata, handles)
% File | Close and Save
vcSaveSESSION;
ieMainClose;
return

% --------------------------------------------------------------------
function refreshMain(handles)
% Called by routines in this function

% Check on File | Wait bar menu item
% h = guihandles;
if ieSessionGet('wait bar');
    set(handles.menuFileWaitBar,'Checked','on');
else
    set(handles.menuFileWaitBar,'Checked','off');
end

return
