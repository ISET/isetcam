function mlOpen(hObject,eventdata,handles)
% Initialize microLensWindow when opening microLensWindow
%
%    mlOpen(hObject,eventdata,handles)
%
% The microlens is from the sensor, and it is always attached to the
% sensor.
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Check for microlens window key and initialize

% Choose default command line output for microLensWindow
% Not sure I understand this. (BW).
handles.output = hObject;
guidata(hObject, handles);

% Turn off some window axis.  Not sure why.
axis off

%% Get the microlens
sensor = vcGetObject('sensor');
if isempty(sensor)
    sensor = sensorCreate;
    ieAddObject(sensor);
    fprintf('Creating and adding default sensor.\n');
end

oi = vcGetObject('oi');
if isempty(oi)
    oi = oiCreate;
    ieAddObject(oi);
    fprintf('Creating and adding default oi.\n');
end

%% See where we stand with microlens and the sensor

ml = sensorGet(sensor,'microLens');
if ~isempty(ml)
    % There is a micro lens structure.  Use it.
else
    % Make up an initial ml structure and use it.
    fprintf('Initializing a microlens structure for the sensor.\n')
    ml     = mlensCreate(sensor,oi);
    sensor = sensorSet(sensor,'ml',ml);
    
    % Put the sensor with the new microlens structure back.
    vcReplaceObject(sensor);
end

mlRefresh(handles,ml);  % Calls mlFillWindowFromML(handles,ml);

return;