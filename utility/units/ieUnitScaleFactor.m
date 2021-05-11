function sFactor = ieUnitScaleFactor(unitName)
%Return  scale factor that converts from meters or seconds to other scales
%
%   sFactor = ieUnitScaleFactor(unitName)
%
% Valid unit names are
%
%  Input assumed to be in meters
%      {'nm','nanometer''nanometers'}
%      {'micron','micrometer','um','microns'}
%      {'mm','millimeter','millimeters'}
%      {'cm','centimeter','centimeters'}
%      {'m','meter','meters'}
%      {'km','kilometer','kilometers'}
%      {'inches','inch'}
%      {'foot','feet'}
%
%  Input assumed to be in seconds
%      {'s','second','sec'}
%      {'ms','millisecond'}
%      {'us','microsecond'}
%
%  Input assumed to be in radians
%      {'degrees','deg'}
%      {'arcmin'}
%      {'arcsec'}
%
% This routine is used in various sceneGet/Set and oiGet/Set operations and
% oiSpatialSupport.  By using this routine, we can specify the units for
% various returned quantities.
%
% Copyright ImagEval Consultants, LLC, 2005.

if ~exist('unitName', 'var') || isempty(unitName), error('Unit name must be defined.'); end

switch lower(unitName)

        % Convert space
    case {'nm', 'nanometer''nanometers'}
        sFactor = 1e9;
    case {'micron', 'micrometer', 'um', 'microns'}
        sFactor = 1e6;
    case {'mm', 'millimeter', 'millimeters'}
        sFactor = 1e3;
    case {'cm', 'centimeter', 'centimeters'}
        sFactor = 1e2;
    case {'m', 'meter', 'meters'}
        sFactor = 1;
    case {'km', 'kilometer', 'kilometers'}
        sFactor = 1e-3;
        % Convert meter to English
    case {'inches', 'inch'}
        sFactor = 39.37007874; % inches/meter
    case {'foot', 'feet'}
        sFactor = 3.280839895; % feet/meter

        % Convert seconds to other unit
    case {'s', 'second', 'sec'}
        sFactor = 1;
    case {'ms', 'millisecond'}
        sFactor = 1e3;
    case {'us', 'microsecond'}
        sFactor = 1e6;

        % Convert radians to other units
    case {'degrees', 'deg'}
        sFactor = 180 / pi;
    case {'arcmin', 'minutes', 'min'}
        sFactor = (180 / pi) * 60;
    case {'arcsec'}
        sFactor = (180 / pi) * 60 * 60;

    otherwise
        errordlg('Unknown spatial unit specification');
end

return;