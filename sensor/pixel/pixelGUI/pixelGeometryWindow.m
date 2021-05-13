function varargout = pixelGeometryWindow(varargin)
% PIXELGEOMETRYWINDOW M-file for pixelGeometryWindow.fig
%      PIXELGEOMETRYWINDOW, by itself, creates a new PIXELGEOMETRYWINDOW or raises the existing
%      singleton*.
%
%      H = PIXELGEOMETRYWINDOW returns the handle to a new PIXELGEOMETRYWINDOW or the handle to
%      the existing singleton*.
%
%      PIXELGEOMETRYWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIXELGEOMETRYWINDOW.M with the given input arguments.
%
%      PIXELGEOMETRYWINDOW('Property','Value',...) creates a new PIXELGEOMETRYWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pixelGeometryWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pixelGeometryWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pixelGeometryWindow

% Last Modified by GUIDE v2.5 25-Jan-2015 18:22:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @pixelGeometryWindow_OpeningFcn, ...
    'gui_OutputFcn', @pixelGeometryWindow_OutputFcn, ...
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


% --- Executes just before pixelGeometryWindow is made visible.
    function pixelGeometryWindow_OpeningFcn(hObject, eventdata, handles, varargin)

        handles.output = hObject;

        % Update handles structure
        guidata(hObject, handles);

        set(handles.btnMethod, 'Value', 1);
        ieFontInit(hObject);

        % Bring this figure to the front
        pixelGeomRefresh(hObject, eventdata, handles);

        return;

        % --- Outputs from this function are returned to the command line.
            function varargout = pixelGeometryWindow_OutputFcn(hObject, eventdata, handles)

                varargout{1} = handles.output;

                return;

                % --- Executes during object creation, after setting all properties.
                    function editHeight_CreateFcn(hObject, eventdata, handles)

                        if ispc
                            set(hObject, 'BackgroundColor', 'white');
                        else
                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                        end

                        return;

                            function editHeight_Callback(hObject, eventdata, handles)

                                sensor = vcGetObject('sensor');
                                sensor = sensorSet(sensor, 'pixel height', str2double(get(hObject, 'String'))*(1e-6));
                                if get(handles.btnMethod, 'Value')
                                    fillfactor = str2double(get(handles.edit1FillFactor, 'String')) / 100;
                                    sensor = pixelCenterFillPD(sensor, fillfactor);
                                end
                                vcReplaceObject(sensor);
                                pixelGeomRefresh(hObject, eventdata, handles);

                                return;

                                % --- Executes during object creation, after setting all properties.
                                    function editWidth_CreateFcn(hObject, eventdata, handles)

                                        if ispc
                                            set(hObject, 'BackgroundColor', 'white');
                                        else
                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                        end
                                        return;

                                        %---------------------------
                                            function editWidth_Callback(hObject, eventdata, handles)

                                                sensor = vcGetObject('sensor');
                                                sensor = sensorSet(sensor, 'pixel width', str2double(get(hObject, 'String'))*(1e-6));
                                                if get(handles.btnMethod, 'Value')
                                                    fillfactor = str2double(get(handles.edit1FillFactor, 'String')) / 100;
                                                    sensor = pixelCenterFillPD(sensor, fillfactor);
                                                end
                                                vcReplaceObject(sensor);
                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                return;

                                                % --- Executes during object creation, after setting all properties.
                                                    function editWidthGap_CreateFcn(hObject, eventdata, handles)

                                                        if ispc
                                                            set(hObject, 'BackgroundColor', 'white');
                                                        else
                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                        end
                                                        return;

                                                        %---------------------------
                                                            function editWidthGap_Callback(hObject, eventdata, handles)

                                                                sensor = vcGetObject('sensor');
                                                                sensor = sensorSet(sensor, 'pixel width gap', str2double(get(hObject, 'String'))*(1e-6));

                                                                % sensor.pixel.widthGap = str2double(get(hObject,'String'))*(1e-6);
                                                                if get(handles.btnMethod, 'Value')
                                                                    fillfactor = str2double(get(handles.edit1FillFactor, 'String')) / 100;
                                                                    sensor = pixelCenterFillPD(sensor, fillfactor);
                                                                end
                                                                vcReplaceObject(sensor);
                                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                                return;

                                                                % --- Executes during object creation, after setting all properties.
                                                                    function editHeightGap_CreateFcn(hObject, eventdata, handles)

                                                                        if ispc
                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                        else
                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                        end

                                                                        %---------------------------
                                                                            function editHeightGap_Callback(hObject, eventdata, handles)
                                                                                %

                                                                                sensor = vcGetObject('sensor');
                                                                                sensor = sensorSet(sensor, 'pixel height gap', str2double(get(hObject, 'String'))*(1e-6));
                                                                                % sensor.pixel.heightGap = str2double(get(hObject,'String'))*(10^(-6));
                                                                                if get(handles.btnMethod, 'Value')
                                                                                    fillfactor = str2double(get(handles.edit1FillFactor, 'String')) / 100;
                                                                                    sensor = pixelCenterFillPD(sensor, fillfactor);
                                                                                end
                                                                                vcReplaceObject(sensor);
                                                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                                                return;

                                                                                % --- Executes during object creation, after setting all properties.
                                                                                    function editPDHeight_CreateFcn(hObject, eventdata, handles)

                                                                                        if ispc
                                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                                        else
                                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                        end

                                                                                        return;

                                                                                        %---------------------------
                                                                                            function editPDHeight_Callback(hObject, eventdata, handles)

                                                                                                sensor = vcGetObject('sensor');
                                                                                                sensor = sensorSet(sensor, 'pixel pd height', str2double(get(hObject, 'String'))*(1e-6));
                                                                                                % sensor.pixel.pdHeight = str2double(get(hObject,'String'))*(10^(-6));
                                                                                                vcReplaceObject(sensor);
                                                                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                                                                return;

                                                                                                % --- Executes during object creation, after setting all properties.
                                                                                                    function editPDWidth_CreateFcn(hObject, eventdata, handles)

                                                                                                        if ispc
                                                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                                                        else
                                                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                                        end

                                                                                                        return;

                                                                                                        %---------------------------
                                                                                                            function editPDWidth_Callback(hObject, eventdata, handles)

                                                                                                                sensor = vcGetObject('sensor');
                                                                                                                sensor = sensorSet(sensor, 'pixel pd width', str2double(get(hObject, 'String'))*(1e-6));
                                                                                                                % sensor.pixel.pdWidth = str2double(get(hObject,'String'))*(10^(-6));
                                                                                                                vcReplaceObject(sensor);

                                                                                                                return;
                                                                                                                % --- Executes during object creation, after setting all properties.
                                                                                                                    function editPDXPos_CreateFcn(hObject, eventdata, handles)

                                                                                                                        if ispc
                                                                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                                                                        else
                                                                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                                                        end

                                                                                                                        return;

                                                                                                                        %---------------------------
                                                                                                                            function editPDXPos_Callback(hObject, eventdata, handles)

                                                                                                                                sensor = vcGetObject('sensor');
                                                                                                                                sensor = sensorSet(sensor, 'pd xpos', str2double(get(hObject, 'String'))*(1e-6));
                                                                                                                                % sensor.pixel.pdXpos = str2double(get(hObject,'String'))*(10^(-6));
                                                                                                                                vcReplaceObject(sensor);
                                                                                                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                                                                                                return;

                                                                                                                                % --- Executes during object creation, after setting all properties.
                                                                                                                                    function editPDYpos_CreateFcn(hObject, eventdata, handles)

                                                                                                                                        if ispc
                                                                                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                                                                                        else
                                                                                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                                                                        end

                                                                                                                                            function editPDYpos_Callback(hObject, eventdata, handles)

                                                                                                                                                sensor = vcGetObject('sensor');
                                                                                                                                                sensor = sensorSet(sensor, 'pd ypos', str2double(get(hObject, 'String'))*(1e-6));
                                                                                                                                                % isa.pixel.pdYpos = str2double(get(hObject,'String'))*(10^(-6));
                                                                                                                                                vcReplaceObject(sensor);
                                                                                                                                                pixelGeomRefresh(hObject, eventdata, handles);

                                                                                                                                                return;

                                                                                                                                                % --- Executes on button press in btnDone.
                                                                                                                                                    function btnDone_Callback(hObject, eventdata, handles)

                                                                                                                                                        close(gcbf);

                                                                                                                                                        % Now, bring forward the sensor image window and refresh its parameters
                                                                                                                                                        %
                                                                                                                                                        hObject = sensorImageWindow;
                                                                                                                                                        handles = guihandles(hObject);
                                                                                                                                                        sensorImageWindow('CALLBACK', 'sensorRefresh', hObject, [], handles);

                                                                                                                                                        return;

                                                                                                                                                        % --- Executes during object creation, after setting all properties.
                                                                                                                                                            function edit1FillFactor_CreateFcn(hObject, eventdata, handles)

                                                                                                                                                                if ispc
                                                                                                                                                                    set(hObject, 'BackgroundColor', 'white');
                                                                                                                                                                else
                                                                                                                                                                    set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                                                                                                end

                                                                                                                                                                    function edit1FillFactor_Callback(hObject, eventdata, handles)
                                                                                                                                                                        %
                                                                                                                                                                        % Use the fill factor value to set up a centered photodetector position
                                                                                                                                                                        %

                                                                                                                                                                        sensor = vcGetObject('sensor');
                                                                                                                                                                        fillfactor = str2double(get(handles.edit1FillFactor, 'String')) / 100;
                                                                                                                                                                        sensor = pixelCenterFillPD(sensor, fillfactor);
                                                                                                                                                                        vcReplaceObject(sensor);
                                                                                                                                                                        pixelGeomRefresh(hObject, eventdata, handles);

                                                                                                                                                                        return;


                                                                                                                                                                        % --- Executes on button press in btnMethod.
                                                                                                                                                                            function btnMethod_Callback(hObject, eventdata, handles)
                                                                                                                                                                                %

                                                                                                                                                                                centered = get(hObject, 'Value');
                                                                                                                                                                                if centered, turnOffManual(hObject, eventdata, handles);
                                                                                                                                                                                else turnOnManual(hObject, eventdata, handles); end

                                                                                                                                                                                return;

                                                                                                                                                                                %------------------------------------
                                                                                                                                                                                    function pixelGeomRefresh(hObject, eventdata, handles)
                                                                                                                                                                                        %
                                                                                                                                                                                        %

                                                                                                                                                                                        if get(handles.btnMethod, 'Value'), turnOffManual(hObject, eventdata, handles);
                                                                                                                                                                                        else turnOnManual(hObject, eventdata, handles); end

                                                                                                                                                                                        sensor = vcGetObject('sensor');
                                                                                                                                                                                        PIXEL = sensorGet(sensor, 'pixel');

                                                                                                                                                                                        % Pixel parameters
                                                                                                                                                                                        str = sprintf('%.1f', pixelGet(PIXEL, 'height')*(10^(6)));
                                                                                                                                                                                        set(handles.editHeight, 'string', str);
                                                                                                                                                                                        str = sprintf('%.1f', pixelGet(PIXEL, 'width')*(10^(6)));
                                                                                                                                                                                        set(handles.editWidth, 'string', str);
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'widthGap')*(10^(6)));
                                                                                                                                                                                        set(handles.editWidthGap, 'string', str);
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'heightGap')*(10^(6)));
                                                                                                                                                                                        set(handles.editHeightGap, 'string', str);

                                                                                                                                                                                        % Photodetector parameters
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'pdHeight')*(10^(6)));
                                                                                                                                                                                        set(handles.editPDHeight, 'string', str);
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'pdWidth')*(10^(6)));
                                                                                                                                                                                        set(handles.editPDWidth, 'string', str);
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'pdXpos')*(10^(6)));
                                                                                                                                                                                        set(handles.editPDXPos, 'string', str);
                                                                                                                                                                                        str = sprintf('%.2f', pixelGet(PIXEL, 'pdYpos')*(10^(6)));
                                                                                                                                                                                        set(handles.editPDYpos, 'string', str);

                                                                                                                                                                                        % Fill factor
                                                                                                                                                                                        str = sprintf('%.0f', pixelGet(PIXEL, 'fillfactor')*100);
                                                                                                                                                                                        set(handles.edit1FillFactor, 'String', str);

                                                                                                                                                                                        return;

                                                                                                                                                                                        %----------------------------------------
                                                                                                                                                                                            function turnOffManual(hObject, eventdata, handles)

                                                                                                                                                                                                set(handles.editPDHeight, 'Visible', 'off');
                                                                                                                                                                                                set(handles.editPDWidth, 'Visible', 'off');
                                                                                                                                                                                                set(handles.editPDXPos, 'Visible', 'off');
                                                                                                                                                                                                set(handles.editPDYpos, 'Visible', 'off');
                                                                                                                                                                                                set(handles.txtPDWidth, 'Visible', 'off');
                                                                                                                                                                                                set(handles.txtPDHeight, 'Visible', 'off');
                                                                                                                                                                                                set(handles.txtPhotodetector, 'Visible', 'off');
                                                                                                                                                                                                set(handles.txtHeightPosition, 'Visible', 'off');
                                                                                                                                                                                                set(handles.txtWidthPosition, 'Visible', 'off');

                                                                                                                                                                                                % And turn on the centered detector
                                                                                                                                                                                                set(handles.txtFillFactor, 'Visible', 'on');
                                                                                                                                                                                                set(handles.txtPrct, 'Visible', 'on');
                                                                                                                                                                                                set(handles.edit1FillFactor, 'Visible', 'on');

                                                                                                                                                                                                return;

                                                                                                                                                                                                %----------------------------------------------
                                                                                                                                                                                                    function turnOnManual(hObject, eventdata, handles)

                                                                                                                                                                                                        set(handles.editPDHeight, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.editPDWidth, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.editPDXPos, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.editPDYpos, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.txtPDWidth, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.txtPDHeight, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.txtPhotodetector, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.txtHeightPosition, 'Visible', 'on');
                                                                                                                                                                                                        set(handles.txtWidthPosition, 'Visible', 'on');

                                                                                                                                                                                                        % And turn off the centered detector
                                                                                                                                                                                                        set(handles.txtFillFactor, 'Visible', 'off');
                                                                                                                                                                                                        set(handles.txtPrct, 'Visible', 'off');
                                                                                                                                                                                                        set(handles.edit1FillFactor, 'Visible', 'off');

                                                                                                                                                                                                        return;
