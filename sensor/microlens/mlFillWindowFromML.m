function mlFillWindowFromML(handles, ml)
%Fill Microlens window display values from the microlens structure data
%
%   mlFillWindowFromML(handles,ml)
%
% handles:  Handles to the microlens window
% ml:       The microlens structure
%
% Imageval Consulting, LLC, 2005

% Fill up the display fields in the window.
val = mlensGet(ml, 'chief ray angle');
set(handles.editChiefRay, 'string', sprintf('%.1f', val));

val = mlensGet(ml, 'wavelength');
set(handles.editWave, 'string', sprintf('%.0f', val));

val = mlensGet(ml, 'source fnumber');
set(handles.editFNumber, 'string', sprintf('%.2f', val));

val = mlensGet(ml, 'source focallength', 'mm');
set(handles.editImageFocalLength, 'string', sprintf('%.2f', val));

val = mlensGet(ml, 'mlfocal length', 'microns');
set(handles.editMLFocalLength, 'string', sprintf('%.2f', val));

val = mlensGet(ml, 'fnumber');
set(handles.editMLFNumber, 'string', sprintf('%.2f', val));

val = mlensGet(ml, 'offset');
set(handles.editMLOffset, 'string', sprintf('%.2f', val));

set(handles.txtUpdateBox, 'BackgroundColor', [0.831, 0.816, 0.784]);

end