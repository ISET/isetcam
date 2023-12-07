function xy = vcLineSelect(obj,objFig)
% Select (x,y) coordinate that determines a line.
%
%   xy = vcLineSelect(obj,[objFig])
%
%  This routine uses getpts() on the ISET window corresponding to the ISET
%  object. The legitimate objects are SCENE,OI, SENSOR, and VCIMAGE.  A
%  message is placed in the window asking the user to select points.
%
% Example:
%   xy = vcLineSelect(vcGetObject('isa'));
%
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:
%   vcPointSelect, vcLineSelect, vcROISelect, ieGetXYCoords

error('Deprecated.  Use iePointSelect');

end
