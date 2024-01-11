function sSupport = oiSpatialSupport(oi,units)
%Calculate the spatial positions of the optical image sample points
%
%   sSupport = oiSpatialSupport(oi,[units = 'meters'] )
%
% Determine the spatial support for the optical image. The positions are
% specified in x and y positions measured on the surface of the image
% sensor. The units (meters, mm, um) can be specified.
%
% Examples:
%  sSupportmm = oiSpatialSupport(oi,'millimeters');
%  sSupportum = oiSpatialSupport(oi,'microns');
%  sSupportm = oiSpatialSupport(oi);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('units'), units = 'meters'; end

sr = oiGet(oi,'spatialResolution',units);
nRows = oiGet(oi,'rows');
nCols = oiGet(oi,'cols');

if isempty(nRows) || isempty(nCols), errordlg('No optical image data.'); return; end

sSupport.y = linspace(-nRows*sr(1)/2 + sr(1)/2, nRows*sr(1)/2 - sr(1)/2,nRows);
sSupport.x = linspace(-nCols*sr(2)/2 + sr(2)/2,nCols*sr(2)/2 - sr(2)/2,nCols);

end