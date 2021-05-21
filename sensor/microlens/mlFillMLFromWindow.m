function ml = mlFillMLFromWindow(handles,ml)
% Fill the microlens structure with values in the window
%
%   ml = mlFillMLFromWindow(handles,ml)
%
% Reads the variables from the window interface into the ml structure.
%
%
% Copyright Imageval Consulting, LLC, 2005


ml = mlensSet(ml,'chief ray angle',str2double(get(handles.editChiefRay,'string')));    % Deg

ml = mlensSet(ml,'wavelength',str2double(get(handles.editWave,'string')));      % Nanometers

ml = mlensSet(ml,'source fnumber',str2double(get(handles.editFNumber,'string'))); %

v = str2double(get(handles.editImageFocalLength,'string')); % In mm
ml = mlensSet(ml,'source focal length',v*1e-3);             % Convert mm to meters

v = str2double(get(handles.editMLFocalLength,'string'))/ieUnitScaleFactor('microns');
ml = mlensSet(ml,'ml focal length',v);

v = str2double(get(handles.editFNumber,'string'))/ieUnitScaleFactor('microns');
ml = mlensSet(ml,'ml fnumber',v);

ml = mlensSet(ml,'offset',str2double(get(handles.editMLOffset,'string')));    %Stored in microns


return;