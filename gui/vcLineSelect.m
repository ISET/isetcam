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
%{
if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
if ieNotDefined('objFig'), objFig = vcGetFigure(obj); end

% Select points.
hndl = guihandles(objFig);
msg = sprintf('Right click to select one point.');
ieInWindowMessage(msg,hndl);

[x,y] = getpts(objFig);
nPoints = length(x);
if nPoints > 1
    warning('ISET:vcLineSelect1','%.0f points selected. returning N-1 point',nPoints);
    xy = [round(x(end-1)), round(y(end-1))];
else
    xy = [round(x), round(y)];
end

ieInWindowMessage('',hndl);
%}

end
