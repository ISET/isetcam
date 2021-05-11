function varargout = cfaDesign(varargin)
% CFADESIGN M-file for cfaDesign.fig
%      CFADESIGN, by itself, creates a new CFADESIGN or raises the existing
%      singleton*.
%
%      H = CFADESIGN returns the handle to a new CFADESIGN or the handle to
%      the existing singleton*.
%
%      CFADESIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CFADESIGN.M with the given input arguments.
%
%      CFADESIGN('Property','Value',...) creates a new CFADESIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cfaDesign_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cfaDesign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cfaDesign

% Last Modified by GUIDE v2.5 06-Feb-2008 17:25:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @cfaDesign_OpeningFcn, ...
    'gui_OutputFcn', @cfaDesign_OutputFcn, ...
    'gui_LayoutFcn', [], ...
    'gui_Callback', []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cfaDesign is made visible.
    function cfaDesign_OpeningFcn(hObject, eventdata, handles, varargin)
        % This function has no output args, see OutputFcn.
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        % varargin   command line arguments to cfaDesign (see VARARGIN)

        % Choose default command line output for cfaDesign
        handles.output = hObject;

        % Update handles structure
        guidata(hObject, handles);

        % UIWAIT makes cfaDesign wait for user response (see UIRESUME)
        % uiwait(handles.cfaDesign);

        % Fill the edit text boxes in the panel on the left
        sensor = vcGetObject('sensor');
        nFilters = sensorGet(sensor, 'nFilters');
        cfaPattern = sensorGet(sensor, 'pattern');
        [nRows, nCols] = size(cfaPattern);

        set(handles.editFilters, 'string', num2str(nFilters));
        set(handles.editRows, 'string', num2str(nRows));
        set(handles.editCols, 'string', num2str(nCols));

        % Plot the filter spectra

        % Set the toggle buttons

        % Fill the slots in the pulldown for filter select

        % Show the CFA image

        return;

        % --- Outputs from this function are returned to the command line.
            function varargout = cfaDesign_OutputFcn(hObject, eventdata, handles)
                % varargout  cell array for returning output args (see VARARGOUT);
                % hObject    handle to figure
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)

                % Get default command line output from handles structure
                varargout{1} = handles.output;


                % --- Executes on button press in btnTemplate.
                    function btnTemplate_Callback(hObject, eventdata, handles)
                        % hObject    handle to btnTemplate (see GCBO)
                        % eventdata  reserved - to be defined in a future version of MATLAB
                        % handles    structure with handles and user data (see GUIDATA)


                        % --- Executes on selection change in popFilterSelect.
                            function popFilterSelect_Callback(hObject, eventdata, handles)
                                % hObject    handle to popFilterSelect (see GCBO)
                                % eventdata  reserved - to be defined in a future version of MATLAB
                                % handles    structure with handles and user data (see GUIDATA)

                                % Hints: contents = get(hObject,'String') returns popFilterSelect contents as cell array
                                %        contents{get(hObject,'Value')} returns selected item from popFilterSelect


                                % --- Executes during object creation, after setting all properties.
                                    function popFilterSelect_CreateFcn(hObject, eventdata, handles)
                                        % hObject    handle to popFilterSelect (see GCBO)
                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                        % handles    empty - handles not created until after all CreateFcns called

                                        % Hint: popupmenu controls usually have a white background on Windows.
                                        %       See ISPC and COMPUTER.
                                        if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
                                            set(hObject, 'BackgroundColor', 'white');
                                        end


                                        % --- Executes on button press in pushImport.
                                            function pushImport_Callback(hObject, eventdata, handles)
                                                % hObject    handle to pushImport (see GCBO)
                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                % handles    structure with handles and user data (see GUIDATA)


                                                % --- Executes on button press in pushEdit.
                                                    function pushEdit_Callback(hObject, eventdata, handles)
                                                        % hObject    handle to pushEdit (see GCBO)
                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                        % handles    structure with handles and user data (see GUIDATA)


                                                        % --- Executes on button press in pushCreate.
                                                            function pushCreate_Callback(hObject, eventdata, handles)
                                                                % hObject    handle to pushCreate (see GCBO)
                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                % handles    structure with handles and user data (see GUIDATA)


                                                                % % --- Executes on button press in pushImport.
                                                                % function pushbutton9_Callback(hObject, eventdata, handles)
                                                                % % hObject    handle to pushImport (see GCBO)
                                                                % % eventdata  reserved - to be defined in a future version of MATLAB
                                                                % % handles    structure with handles and user data (see GUIDATA)
                                                                %
                                                                %
                                                                % % --- Executes on button press in pushEdit.
                                                                % function pushbutton10_Callback(hObject, eventdata, handles)
                                                                % % hObject    handle to pushEdit (see GCBO)
                                                                % % eventdata  reserved - to be defined in a future version of MATLAB
                                                                % % handles    structure with handles and user data (see GUIDATA)


                                                                    function editFilters_Callback(hObject, eventdata, handles)
                                                                        % hObject    handle to editFilters (see GCBO)
                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                        % handles    structure with handles and user data (see GUIDATA)

                                                                        % Hints: get(hObject,'String') returns contents of editFilters as text
                                                                        %        str2double(get(hObject,'String')) returns contents of editFilters as a double


                                                                        % --- Executes during object creation, after setting all properties.
                                                                            function editFilters_CreateFcn(hObject, eventdata, handles)
                                                                                % hObject    handle to editFilters (see GCBO)
                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                % handles    empty - handles not created until after all CreateFcns called

                                                                                % Hint: edit controls usually have a white background on Windows.
                                                                                %       See ISPC and COMPUTER.
                                                                                if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
                                                                                    set(hObject, 'BackgroundColor', 'white');
                                                                                end


                                                                                    function editRows_Callback(hObject, eventdata, handles)
                                                                                        % hObject    handle to editRows (see GCBO)
                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                        % handles    structure with handles and user data (see GUIDATA)

                                                                                        % Hints: get(hObject,'String') returns contents of editRows as text
                                                                                        %        str2double(get(hObject,'String')) returns contents of editRows as a double


                                                                                        % --- Executes during object creation, after setting all properties.
                                                                                            function editRows_CreateFcn(hObject, eventdata, handles)
                                                                                                % hObject    handle to editRows (see GCBO)
                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                % handles    empty - handles not created until after all CreateFcns called

                                                                                                % Hint: edit controls usually have a white background on Windows.
                                                                                                %       See ISPC and COMPUTER.
                                                                                                if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
                                                                                                    set(hObject, 'BackgroundColor', 'white');
                                                                                                end


                                                                                                    function editCols_Callback(hObject, eventdata, handles)
                                                                                                        % hObject    handle to editCols (see GCBO)
                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                        % handles    structure with handles and user data (see GUIDATA)

                                                                                                        % Hints: get(hObject,'String') returns contents of editCols as text
                                                                                                        %        str2double(get(hObject,'String')) returns contents of editCols as a double


                                                                                                        % --- Executes during object creation, after setting all properties.
                                                                                                            function editCols_CreateFcn(hObject, eventdata, handles)
                                                                                                                % hObject    handle to editCols (see GCBO)
                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                % handles    empty - handles not created until after all CreateFcns called

                                                                                                                % Hint: edit controls usually have a white background on Windows.
                                                                                                                %       See ISPC and COMPUTER.
                                                                                                                if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
                                                                                                                    set(hObject, 'BackgroundColor', 'white');
                                                                                                                end


                                                                                                                % --------------------------------------------------------------------
                                                                                                                    function menuFile_Callback(hObject, eventdata, handles)
                                                                                                                        % hObject    handle to menuFile (see GCBO)
                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                        % --------------------------------------------------------------------
                                                                                                                            function menuEdit_Callback(hObject, eventdata, handles)
                                                                                                                                % hObject    handle to menuEdit (see GCBO)
                                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                % --------------------------------------------------------------------
                                                                                                                                    function menuHelp_Callback(hObject, eventdata, handles)
                                                                                                                                        % hObject    handle to menuHelp (see GCBO)
                                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                        % --------------------------------------------------------------------
                                                                                                                                            function menuFileSave_Callback(hObject, eventdata, handles)
                                                                                                                                                % hObject    handle to menuFileSave (see GCBO)
                                                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                % --------------------------------------------------------------------
                                                                                                                                                    function menuFileImport_Callback(hObject, eventdata, handles)
                                                                                                                                                        % hObject    handle to menuFileImport (see GCBO)
                                                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                        % --------------------------------------------------------------------
                                                                                                                                                            function menuFileClose_Callback(hObject, eventdata, handles)
                                                                                                                                                                close(handles.cfaDesign);
                                                                                                                                                                return;

                                                                                                                                                                % --------------------------------------------------------------------
                                                                                                                                                                    function menuEditCreate_Callback(hObject, eventdata, handles)
                                                                                                                                                                        % hObject    handle to menuEditCreate (see GCBO)
                                                                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                                        % --------------------------------------------------------------------
                                                                                                                                                                            function menuEditFilter_Callback(hObject, eventdata, handles)
                                                                                                                                                                                % hObject    handle to menuEditFilter (see GCBO)
                                                                                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                                % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                                                % --------------------------------------------------------------------
                                                                                                                                                                                    function menuHelpCFA_Callback(hObject, eventdata, handles)
                                                                                                                                                                                        % hObject    handle to menuHelpCFA (see GCBO)
                                                                                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                                                        % --------------------------------------------------------------------
                                                                                                                                                                                            function menuHelpISET_Callback(hObject, eventdata, handles)
                                                                                                                                                                                                % hObject    handle to menuHelpISET (see GCBO)
                                                                                                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                                                % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                                                                % --------------------------------------------------------------------
                                                                                                                                                                                                    function menuEditDelete_Callback(hObject, eventdata, handles)
                                                                                                                                                                                                        % hObject    handle to menuEditDelete (see GCBO)
                                                                                                                                                                                                        % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                                                        % handles    structure with handles and user data (see GUIDATA)


                                                                                                                                                                                                        % --------------------------------------------------------------------
                                                                                                                                                                                                            function menuFileUpdate_Callback(hObject, eventdata, handles)
                                                                                                                                                                                                                % hObject    handle to menuFileUpdate (see GCBO)
                                                                                                                                                                                                                % eventdata  reserved - to be defined in a future version of MATLAB
                                                                                                                                                                                                                % handles    structure with handles and user data (see GUIDATA)

                                                                                                                                                                                                                % Fill the sesnsor entries with the values in the GUI
                                                                                                                                                                                                                sensor = vcGetObject('sensor');
                                                                                                                                                                                                                sensor = gui2Sensor(handles, sensor);

                                                                                                                                                                                                                vcReplaceAndSelect(sensor);

                                                                                                                                                                                                                return;

                                                                                                                                                                                                                % -------------------------------------------------------------------
                                                                                                                                                                                                                    function sensor = gui2sensor(handles, sensor)
                                                                                                                                                                                                                        % Fill up the sensor fields using the information in the GUI boxes
                                                                                                                                                                                                                        %
                                                                                                                                                                                                                        % guidata related
                                                                                                                                                                                                                        return;

                                                                                                                                                                                                                        % -------------------------------------------------------------------
                                                                                                                                                                                                                            function handles = sensor2gui(handles, sensor)
                                                                                                                                                                                                                                % Fill up the gui user data fields using the information in the sensor
                                                                                                                                                                                                                                % guidata related

                                                                                                                                                                                                                                return;
