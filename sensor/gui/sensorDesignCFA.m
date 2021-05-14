function varargout = sensorDesignCFA(varargin)
%Graphical user interface to design CFA properties
%See also cfaDesign - which could be the next generation?
%
% varargout = sensorDesignCFA(varargin)
%
%   `  Design the color filter array (CFA) for the current sensor.  If the
%      sensor is monochrome, one filter is selected.  If the sensor is
%      color, the user selects the position and identity of four color
%      filters in the 2x2 array. The user can also select new filters and
%      scale the peak QE of each filter.
%
%      SENSORDESIGNCFA, by itself, creates a new SENSORDESIGNCFA or raises the existing
%      singleton*.
%
%      H = SENSORDESIGNCFA returns the handle to a new SENSORDESIGNCFA or the handle to
%      the existing singleton*.
%
%      SENSORDESIGNCFA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SENSORDESIGNCFA.M with the given input arguments.
%
%      SENSORDESIGNCFA('Property','Value',...) creates a new SENSORDESIGNCFA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sensorDesignCFA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sensorDesignCFA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright ImagEval Consultants, LLC, 2005

% Edit the above text to modify the response to help sensorDesignCFA

% Last Modified by GUIDE v2.5 08-Jan-2016 23:10:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @sensorDesignCFA_OpeningFcn, ...
    'gui_OutputFcn',  @sensorDesignCFA_OutputFcn, ...
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


% --- Executes just before sensorDesignCFA is made visible.
function sensorDesignCFA_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for sensorDesignCFA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% [val,isa] = vcGetSelectedObject('ISA');
% filterNames = cellstr(sensorGet(isa,'filternames')');

sensorDesignCFARefresh(handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = sensorDesignCFA_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;


function menuFile_Callback(hObject,eventdata,handles)
return;

% --------------------------------------------------------------------
function menuFileSaveFilters_Callback(hObject, eventdata, handles)

[val,isa] = vcGetSelectedObject('ISA');
ieSaveColorFilters(isa);

return;

% --------------------------------------------------------------------
function menuClose_Callback(hObject, eventdata, handles)
%
% Clean up the filter names and the filter spectra.  If the block was set
% up to monochrome, get rid of stuff.  If there are any unused filters, get
% rid of them.
%

[val,isa] = vcGetSelectedObject('ISA');

contents = get(handles.popBlockSize,'String');
blockSize = contents{get(handles.popBlockSize,'Value')};

filterSpectra = sensorGet(isa,'filterspectra');
filterNames   = sensorGet(isa,'filternames');
nFilters      = sensorGet(isa,'nfilters');
pattern       = sensorGet(isa,'pattern');

switch lower(blockSize)
    case '1 (monochrome)'
        toKeep = pattern(1);
        filterSpectra = filterSpectra(:,toKeep);
        newFilterNames{1} = filterNames{toKeep};
        filterNames = newFilterNames;
        pattern = 1;
        
    case '2x2'
        
        % See which sensors are used in p attern
        usedFilters = unique(sort(pattern(:)));
        if length(usedFilters) == sensorGet(isa,'nfilters')
            % do nothing
        elseif length(usedFilters) < nFilters
            warndlg('Removing unused filters from ISA');
            
            % Remove the unused spectra
            filterSpectra = filterSpectra(:,usedFilters);
            
            % Move the names
            for ii=1:length(usedFilters)
                newFilterNames{ii} = filterNames{usedFilters(ii)};
            end
            filterNames = newFilterNames;
            
            % Adjust the pattern by reducing the value of any terms greater than a removed filter.
            for ii=1:nFilters
                m = find(~[usedFilters - ii]);
                if isempty(m)
                    l = pattern >= ii;
                    if ~isempty(l), pattern(l) = pattern(l) - 1; end
                end
            end
            
        else
            error('The pattern is specifying filters that are not present.');
        end
        
    otherwise
        error('Unknown block size setting.');
end

% isa = sensorSet(isa,'unitblock',sensorUnitBlock(isa));
isa = sensorSet(isa,'filterspectra',filterSpectra);
isa = sensorSet(isa,'filterNames',filterNames);

% Pattern's shape now codes the unit block shape
isa = sensorSet(isa,'pattern',pattern);

% This part could be avoided on a cancel, rather than save and close
isa = sensorClearData(isa);
isa.consistency = 0;            % False.  Force recomputation.
vcReplaceObject(isa,val);

% Close this figure and bring forward the sensor image window and refresh its parameters
close(gcbf);
hObject = sensorImageWindow;
handles = guihandles(hObject);
sensorImageWindow('CALLBACK','sensorRefresh',hObject,[],handles);

return;


% --------------------------------------------------------------------
function menuRefresh_Callback(hObject, eventdata, handles)
sensorDesignCFARefresh(handles);
return;


% --------------------------------------------------------------------
function menuSaveCFA_Callback(hObject, eventdata, handles)
[val,ISA] = vcGetSelectedObject('ISA');
sensorCfaSave(ISA);
return;

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuScaleQE_Callback(hObject, eventdata, handles)
%
% Set the peak QE in each of the three color filters

[val,isa] = vcGetSelectedObject('ISA');
cf = sensorGet(isa,'filterspectra');
filterNames = sensorGet(isa,'filternames');
currentPeaks = max(cf);
for ii=1:size(cf,2)
    prompt{ii} = sprintf('Set %s peak',char(filterNames{ii}));
    def{ii}=num2str(currentPeaks(ii));
end

dlgTitle='Scale peak transmission'; lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer), return; end

for ii=1:length(answer), newPeaks(ii) = str2num(answer{ii}); end
cf = cf*diag(newPeaks./currentPeaks);
isa = sensorSet(isa,'filterspectra',cf);

vcReplaceObject(isa,val);
sensorDesignCFARefresh(handles);

return;


% --- Executes on button press in btnScale.
function btnScale_Callback(hObject, eventdata, handles)
menuScaleQE_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditEquateTransmittances_Callback(hObject, eventdata, handles)
% Equalizes the area under the filter curves and sets the overall peak to
% 1.0.

[val,isa] = vcGetSelectedObject('ISA');

filters = sensorGet(isa,'filterspectra');
filters = sensorEquateTransmittances(filters);

isa = sensorSet(isa,'filterSpectra',filters);
vcReplaceObject(isa,val);
sensorDesignCFARefresh(handles);

return;

% --- Executes during object creation, after setting all properties.
function popName1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popName1.
function popName1_Callback(hObject, eventdata, handles)
%
% These routines reset the entries in the pattern variable.  We find the
% name of the selected filter for each position (in this case position 1),
% and then we place the filter number in that position in isa.cfa.pattern.

% This is the selected filter name
contents = get(hObject,'String');
c = contents{get(hObject,'Value')};
resetColorOrder(handles);
sensorDesignCFARefresh(handles);

return;

% --- Executes during object creation, after setting all properties.
function popName2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popName2.
function popName2_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
c = contents{get(hObject,'Value')};
resetColorOrder(handles);
sensorDesignCFARefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function popName3_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popName3.
function popName3_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
c = contents{get(hObject,'Value')};
resetColorOrder(handles);
sensorDesignCFARefresh(handles);

return;

% --- Executes during object creation, after setting all properties.
function popName4_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;


% --- Executes on selection change in popName4.
function popName4_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
c = contents{get(hObject,'Value')};
resetColorOrder(handles);
sensorDesignCFARefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function popBlockSize_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popBlockSize.
function popBlockSize_Callback(hObject, eventdata, handles)
sensorDesignCFARefresh(handles);
return;


% --- Executes during object creation, after setting all properties.
function popEdit_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popEdit.
function popEdit_Callback(hObject, eventdata, handles)

[val,isa] = vcGetSelectedObject('ISA');
contents = get(hObject,'String');

switch contents{get(hObject,'Value')}
    
    case 'Add Filter'
        isa = sensorAddFilter(isa);
        
    case 'Replace Filter'
        isa = sensorReplaceFilter(isa);
        
    case 'Delete Filter'
        isa = sensorDeleteFilter(isa);
        
    otherwise
        error('bad selection.');
end

vcReplaceObject(isa,val);
sensorDesignCFARefresh(handles);

return;


%---------------------------
function resetColorOrder(handles)
%
% Gather up the filternames.

[val,isa] = vcGetSelectedObject('ISA');
filterNames = sensorGet(isa,'filternames');

contents = get(handles.popBlockSize,'String');
blockSize = contents{get(handles.popBlockSize,'Value')};

switch lower(blockSize)
    case '1 (monochrome)'
        pattern(1) = get(handles.popName1,'Value');
    case '2x2'
        pattern(1,1) = get(handles.popName1,'Value');
        pattern(2,1) = get(handles.popName2,'Value');
        pattern(1,2) = get(handles.popName3,'Value');
        pattern(2,2) = get(handles.popName4,'Value');
    otherwise
        error('Unknown block style');
end

isa = sensorSet(isa,'pattern',pattern);
vcReplaceObject(isa,val);

return;


% --------------------------------------------------------------------
function fileFontSize_Callback(hObject, eventdata, handles)
% hObject    handle to fileFontSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fSize = ieFontSizeSet(handles.figure1);
set(handles.text1,'fontsize',fSize + 4);
set(handles.txtBlockSize,'fontsize',fSize + 2);


return;
