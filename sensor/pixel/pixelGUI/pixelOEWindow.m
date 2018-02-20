function varargout = pixelOEWindow(varargin)
% PIXELOEWINDOW M-file for pixelOEWindow.fig
%      PIXELOEWINDOW, by itself, creates a new PIXELOEWINDOW or raises the existing
%      singleton*.
%
%      H = PIXELOEWINDOW returns the handle to a new PIXELOEWINDOW or the handle to
%      the existing singleton*.
%
%      PIXELOEWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIXELOEWINDOW.M with the given input arguments.
%
%      PIXELOEWINDOW('Property','Value',...) creates a new PIXELOEWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pixelOEWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pixelOEWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pixelOEWindow

% Last Modified by GUIDE v2.5 19-Oct-2015 20:17:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pixelOEWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @pixelOEWindow_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pixelOEWindow is made visible.
function pixelOEWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pixelOEWindow (see VARARGIN)

% Choose default command line output for pixelOEWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

btnRefresh_Callback(hObject,eventdata,handles);

return;


% --- Outputs from this function are returned to the command line.
function varargout = pixelOEWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --- Executes during object creation, after setting all properties.
function editRefractiveIndices_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editRefractiveIndices_Callback(hObject, eventdata, handles)

[val,isa] = vcGetSelectedObject('ISA');
str = get(hObject,'String') ;
isa.pixel.refractiveIndices = eval(str);
vcReplaceObject(isa,val);

return;

% --- Executes during object creation, after setting all properties.
function editLayerThickness_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editLayerThickness_Callback(hObject, eventdata, handles)
%

[val,isa] = vcGetSelectedObject('ISA');
str = get(hObject,'String') ;
isa.pixel.layerThickness = eval(str);
isa.pixel.layerThickness = isa.pixel.layerThickness*10^-6;
vcReplaceObject(isa,val);

return;

% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)

[val,isa] = vcGetSelectedObject('ISA');
pixel = sensorGet(isa,'pixel');
nThickness = length(pixelGet(pixel,'layerthickness'));
nRefractiveIndices = length(pixelGet(pixel,'refractiveindices'));
if (nRefractiveIndices - nThickness) ~= 2
    % Air and silicon are infinite.  We should have two fewer distances
    % than we have material indices of refraction.
    newTxt = sprintf('Please specify %.0f layer thicknesses.',nRefractiveIndices-2);
    ieInWindowMessage(newTxt,handles,3);
    return;
end
close(gcbf);

return;


% --- Executes on button press in btnRefresh.
function btnRefresh_Callback(hObject, eventdata, handles)

[val,isa] = vcGetSelectedObject('ISA');
pixel = sensorGet(isa,'pixel');
d = pixelGet(pixel,'layerthickness')*10^6;
n = pixelGet(pixel,'refractiveindices');

str = sprintf('%.2f ',d); str = ['[ ',str,']']; 
set(handles.editLayerThickness,'String',str);
str = sprintf('%.2f ',n); str = ['[ ',str,']'];
set(handles.editRefractiveIndices,'String',str);

return;
