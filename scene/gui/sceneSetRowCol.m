function varargout = sceneSetRowCol(varargin)
% GUI to set scene row and col (image size)
%
%       varargout = sceneSetRowCol(varargin)
%
%      SCENESETROWCOL, by itself, creates a new SCENESETROWCOL or raises the existing
%      singleton*.
%
%      H = SCENESETROWCOL returns the handle to a new SCENESETROWCOL or the handle to
%      the existing singleton*.
%
%      SCENESETROWCOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCENESETROWCOL.M with the given input arguments.
%
%      SCENESETROWCOL('Property','Value',...) creates a new SCENESETROWCOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sceneSetRowCol_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sceneSetRowCol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright ImagEval Consultants, LLC, 2005.

% Edit the above text to modify the response to help sceneSetRowCol

% Last Modified by GUIDE v2.5 06-Jul-2003 23:54:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @sceneSetRowCol_OpeningFcn, ...
    'gui_OutputFcn', @sceneSetRowCol_OutputFcn, ...
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


% --- Executes just before sceneSetRowCol is made visible.
    function sceneSetRowCol_OpeningFcn(hObject, eventdata, handles, varargin)
        % This function has no output args, see OutputFcn.
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        % varargin   command line arguments to sceneSetRowCol (see VARARGIN)

        % Choose default command line output for sceneSetRowCol
        handles.output = hObject;

        % Update handles structure
        guidata(hObject, handles);

        % These are the variables that will be read from the boxes and returned.
        % They must be defined at least once, so we set them here.
        global newRow;
        global newCol;

        % Determine the current size of the rows and columns and put them in the
        % boxes.  They are not used again.
        [val, scene] = vcGetSelectedObject('SCENE');
        newRow = sceneGet(scene, 'rows');
        newCol = sceneGet(scene, 'cols');

        set(handles.editRows, 'String', newRow);
        set(handles.editCols, 'String', newCol);

        % UIWAIT makes sceneSetRowCol wait for user response (see UIRESUME)
        uiwait(handles.figure1);

        return;

        % --- Outputs from this function are returned to the command line.
            function varargout = sceneSetRowCol_OutputFcn(hObject, eventdata, handles)
                % varargout  cell array for returning output args (see VARARGOUT);
                % hObject    handle to figure
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)

                % Get default command line output from handles structure
                % varargout{1} = handles.output;
                global newRow;
                global newCol;

                varargout{1} = [newRow, newCol];

                return;

                % --- Executes during object creation, after setting all properties.
                    function editRows_CreateFcn(hObject, eventdata, handles)

                        if ispc
                            set(hObject, 'BackgroundColor', 'white');
                        else
                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                        end

                            function editRows_Callback(hObject, eventdata, handles)

                                global newRow;
                                newRow = str2double(get(hObject, 'String'));

                                return;

                                % --- Executes during object creation, after setting all properties.
                                    function editCols_CreateFcn(hObject, eventdata, handles)

                                        if ispc
                                            set(hObject, 'BackgroundColor', 'white');
                                        else
                                            set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
                                        end


                                            function editCols_Callback(hObject, eventdata, handles)

                                                global newCol;
                                                newCol = str2double(get(hObject, 'String'));

                                                return;

                                                % --- Executes on button press in btnDone.
                                                    function btnDone_Callback(hObject, eventdata, handles)

                                                        sceneSetRowCol_OutputFcn(hObject, eventdata, handles);
                                                        global newRow;
                                                        global newCol;

                                                        clear newRow, newCol;

                                                        % uiresume(handles.figure1);
                                                        close(gcbf);

                                                        return;
