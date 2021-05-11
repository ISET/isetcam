function varargout = imageSetHarmonic(varargin)
% UI to read in the parameters of a harmonic pattern.
%
%  varargout = imageSetHarmonic(varargin)
%  IMAGESETHARMONIC M-file for imageSetHarmonic.fig
%
%      imageSetHarmonic, by itself, creates a new IMAGEHARMONIC or raises the existing
%      singleton*.
%
%      H = imageSetHarmonic returns the handle to a new IMAGEHARMONIC or the handle to
%      the existing singleton*.
%
%      I have not found a good way to return the parameters of the harmonic
%      function.  These are frequency, contrast, phase, angle, Gaussian
%      window, and row,col.  To get them back, I create global parms, read
%      it, and then destroy it. This is really dumb.  There must be a better way.
%
%          parms.freq, parms.contras, parms.ph, parms.ang, parms.row,
%          parms.col, parms.GaborFlag
%
%      imageSetHarmonic('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESETHARMONIC.M with the given input arguments.
%
%      imageSetHarmonic('Property','Value',...) creates a new IMAGESETHARMONIC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageSetHarmonic_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageSetHarmonic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright ImagEval Consultants, LLC, 2003.

% Edit the above text to modify the response to help imageSetHarmonic

% Last Modified by GUIDE v2.5 23-Aug-2003 09:34:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @imageSetHarmonic_OpeningFcn, ...
    'gui_OutputFcn', @imageSetHarmonic_OutputFcn, ...
    'gui_LayoutFcn', [], ...
    'gui_Callback', []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
return;


% --- Executes just before imageSetHarmonic is made visible.
    function imageSetHarmonic_OpeningFcn(hObject, eventdata, handles, varargin)

        % Choose default command line output for imageSetHarmonic
        handles.output = hObject;

        % Update handles structure
        guidata(hObject, handles);

        % UIWAIT makes imageSetHarmonic wait for user response (see UIRESUME)
        % uiwait(handles.figure1);

        return;

        % --- Outputs from this function are returned to the command line.
            function varargout = imageSetHarmonic_OutputFcn(hObject, eventdata, handles)

                if ieNotDefined('parms'), parms = []; end

                varargout{1} = handles.output;
                varargout{2} = btnDone_Callback(hObject, eventdata, handles, 0);

                return;

                % --- Executes during object creation, after setting all properties.
                    function editFreq_CreateFcn(hObject, eventdata, handles)

                        if ispc
                            set(hObject, 'BackgroundColor', 'white');
                        else
                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                        end
                        return;

                            function editFreq_Callback(hObject, eventdata, handles)
                                return;

                                % --- Executes during object creation, after setting all properties.
                                    function editContrast_CreateFcn(hObject, eventdata, handles)

                                        if ispc
                                            set(hObject, 'BackgroundColor', 'white');
                                        else
                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                        end
                                        return;

                                            function editContrast_Callback(hObject, eventdata, handles)
                                                return;

                                                % --- Executes during object creation, after setting all properties.
                                                    function editRow_CreateFcn(hObject, eventdata, handles)

                                                        if ispc
                                                            set(hObject, 'BackgroundColor', 'white');
                                                        else
                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                        end
                                                        return;


                                                            function editRow_Callback(hObject, eventdata, handles)
                                                                return;


                                                                % --- Executes during object creation, after setting all properties.
                                                                    function editCol_CreateFcn(hObject, eventdata, handles)
                                                                        if ispc
                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                        else
                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                        end
                                                                        return;


                                                                            function editCol_Callback(hObject, eventdata, handles)
                                                                                return;


                                                                                % --- Executes during object creation, after setting all properties.
                                                                                    function editPh_CreateFcn(hObject, eventdata, handles)
                                                                                        if ispc
                                                                                            set(hObject, 'BackgroundColor', 'white');
                                                                                        else
                                                                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                        end
                                                                                        return;


                                                                                            function editPh_Callback(hObject, eventdata, handles)
                                                                                                return;

                                                                                                % --- Executes on button press in btnGabor.
                                                                                                    function btnGabor_Callback(hObject, eventdata, handles)
                                                                                                        return;


                                                                                                        % --- Executes during object creation, after setting all properties.
                                                                                                            function editAng_CreateFcn(hObject, eventdata, handles)
                                                                                                                if ispc
                                                                                                                    set(hObject, 'BackgroundColor', 'white');
                                                                                                                else
                                                                                                                    set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                                                                                                end
                                                                                                                return;


                                                                                                                    function editAng_Callback(hObject, eventdata, handles)
                                                                                                                        return;


                                                                                                                        % --- Executes on button press in btnDone.
                                                                                                                            function parms = btnDone_Callback(hObject, eventdata, handles, closeMe)

                                                                                                                                if ieNotDefined('closeMe'), closeMe = 1; end

                                                                                                                                global parms

                                                                                                                                parms.freq = str2num(get(handles.editFreq, 'String'));
                                                                                                                                parms.contrast = str2num(get(handles.editContrast, 'String'));
                                                                                                                                parms.ph = str2num(get(handles.editPh, 'String'));
                                                                                                                                parms.ang = str2num(get(handles.editAng, 'String'));
                                                                                                                                parms.row = str2num(get(handles.editRow, 'String'));
                                                                                                                                parms.col = str2num(get(handles.editCol, 'String'));
                                                                                                                                parms.GaborFlag = get(handles.btnGabor, 'Value');

                                                                                                                                if closeMe, close(gcbf); end

                                                                                                                                return;
