function oi = oiClearData(oi)
%Clear data from optical image structure
%
%   oi = oiClearData(oi)
%
% Clear the data from the optical image structure as well as the data in
% the optics structure within it.
%
% Clear the optics data is not necessarily a good idea, as these data are
% mainly the PSF value.  The optics are treated as a special case in
% vcImportObject where the default is to preserve the data.  The default is
% to clear for other objects (sensor, vcimage, and so forth).
%
% It is also possible to clear the optics data using opticsClearData.
%
% Copyright ImagEval Consultants, LLC, 2003.

bitDepth = oiGet(oi, 'bit depth');
oi = oiSet(oi, 'data', []);
oi = oiSet(oi, 'bit depth', bitDepth);

oi = oiSet(oi, 'wangular', []);
oi = oiSet(oi, 'depth map', []);

optics = opticsClearData(oiGet(oi, 'optics'));

oi = oiSet(oi, 'optics', optics);

return;