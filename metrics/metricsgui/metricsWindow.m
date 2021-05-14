function varargout = metricsWindow(varargin)
%Graphical user interface to the Metrics Window.
%
%   varargout = metricsWindow(varargin)
%
%
%  This window allows a comparison between two of the images in the image
%  processing window (vcimage).  Various metrics can be computed between
%  pairs of processed images.
%
%  METRICSWINDOW, by itself, creates a new METRICSWINDOW or raises the
%  existing singleton*.
%
%  H = METRICSWINDOW returns the handle to a new METRICSWINDOW or the
%  handle to the existing singleton*.
%
%  METRICSWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in METRICSWINDOW.M with the given input
%  arguments.
%
%  METRICSWINDOW('Property','Value',...) creates a new METRICSWINDOW or
%  raises the existing singleton*.  Starting from the left, property value
%  pairs are applied to the GUI before metricsWindow_OpeningFunction gets
%  called.  An unrecognized property name or invalid value makes property
%  application stop.  All inputs are passed to metricsWindow_OpeningFcn via
%  varargin.
%
%  *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% Copyright ImagEval Consultants, LLC, 2003.

% Edit the above text to modify the response to help metricsWindow

% Last Modified by GUIDE v2.5 19-Oct-2015 20:17:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @metricsWindow_OpeningFcn, ...
    'gui_OutputFcn',  @metricsWindow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before metricsWindow is made visible.
function metricsWindow_OpeningFcn(hObject, eventdata, handles, varargin)
%

global vcSESSION

vcSetFigureHandles('METRICS',hObject,eventdata,handles);

% Choose default command line output for metricsWindow
handles.output = hObject;

%  Place to store the results of metrics calculations
handles.metricImage = [];

% Update handles structure
guidata(hObject, handles);
axes(handles.imgMetric); axis image; axis off;
axes(handles.img1); axis image; axis off;
axes(handles.img2); axis image; axis off;

ieFontInit(hObject);

% In this case, hObject is the metrics window itself, I think.
metricsRefresh(handles)

return;


% --- Outputs from this function are returned to the command line.
function varargout = metricsWindow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;

% --- Executes during object creation, after setting all properties.
function popImageList1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popImageList1.
function popImageList1_Callback(hObject, eventdata, handles)
% Values are stored in this popimage list, like in the other one.
metricsRefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function popImageList2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;


% --- Executes on selection change in popImageList2.
function popImageList2_Callback(hObject, eventdata, handles)
% Values are stored in this popimage list, like in the other one.
metricsRefresh(handles);
return;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
ieFontSizeSet(handles.figure1);
return;

% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuPlotROIHist_Callback(hObject, eventdata, handles)
plotMetrics(handles);
return;


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
iseHelp('metrics');
return;

% --- Executes during object creation, after setting all properties.
function editGamma_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editGamma_Callback(hObject, eventdata, handles)
% Gamma is stored in the string of this object.
metricsRefresh(handles);
return;

% --- Executes on button press in btnCompute.
function btnCompute_Callback(hObject, eventdata, handles)

% Read the names of the selected vc images that will be used in the metric
% computation
val = metricsGet(handles,'vcipair');

% Convert from cell array to a string
metricName = metricsGet(handles,'currentmetric');

% Compute the metric and attach it to the handles
metricData = metricsCompute(val.vci1,val.vci2,metricName);
handles = metricsSet(handles,'metricData',metricData);

% Attach the handles to the window
guidata(hObject, handles);

metricsRefresh(handles)

return;

% --- Executes during object creation, after setting all properties.
function popMetric_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;


% --- Executes on selection change in popMetric.
function popMetric_Callback(hObject, eventdata, handles)
% Store the metric choice in the handles.
return;


function menuAnalyze_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuClose_Callback(hObject, eventdata, handles)
metricsClose;
return;

% --------------------------------------------------------------------
function menuRefresh_Callback(hObject, eventdata, handles)
metricsRefresh(handles);
return;

% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
metricsSaveImage(gcbf);
return;

% --------------------------------------------------------------------
function menuNewGraphWindow_Callback(hObject, eventdata, handles)
vcNewGraphWin;
return;

% --------------------------------------------------------------------
function menuSaveData_Callback(hObject, eventdata, handles)
metricsSaveData(gcbf)
return;


% --------------------------------------------------------------------
function menuAnalyzeComparePatches_Callback(hObject, eventdata, handles)
% hObject    handle to menuAnalyzeComparePatches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuAnalyzeSummary_Callback(hObject, eventdata, handles)
% hObject    handle to menuAnalyzeSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function menuFileLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileSaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadImagePair_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadImagePair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadImage1_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadImage1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadImage2_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadImage2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadVCI_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadVCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileSaveVCI_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSaveVCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
