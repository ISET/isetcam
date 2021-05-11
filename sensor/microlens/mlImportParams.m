function ml = mlImportParams(ml, optics, pixel)
%Import current optics and pixel parameters to the microlens structure.
%
%   ml = mlImportParams(ml,optics,pixel)
%
% The optics and pixel sent in should be from the currently selected sensor
% and oi objects. The values in them are used to plausibly initialize the
% microlens object.
%
% See also: mlensCreate
%
% Copyright Imageval Consulting, 2005

if ieNotDefined('optics'), errordlg('Optics structure required'); end
if ieNotDefined('pixel'), errordlg('Pixel structure required'); end

%% Get the parameters

% Source
ml.sourceFNumber = opticsGet(optics, 'f number');
ml.sourceFocalLength = opticsGet(optics, 'focal Length'); %Was mm, now meters

% Microlens
ml.focalLength = pixelGet(pixel, 'pixel Depth'); % Was Microns, now meters
diameter = pixelGet(pixel, 'pixel Width'); % Was microns, now meters
ml.fnumber = ml.focalLength / diameter;

end