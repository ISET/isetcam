function [xy, button] = ieGetXYCoords(obj)
%Graphical method for selecting xy position in a window. 
%
%   [xy, button]  = ieGetXYCoords(obj)
%
% This routine works properly when called from the object window.  But when
% called from the command line, it doesn't keep focus on the window.  So,
% we generally use the routines vcLineSelect, vcPointSelect, and
% vcROISelect. 
%
% But this routine does have some nice features, so we keep it around.
% First, it is a one click selection.  Second, it uses nice crosshairs.
%
% The crosshairs are used to select an xy coord in the window associated
% with obj.  This routine does not work properly unless used as a
% callback;  the focus does not switch to the figure properly.  I don't
% understand why.  It does work well when called from within the window
% function itself.  There are some issues with Matlab 6.5 compared to
% Matlab 7.0, too.  (Still not switching focus, 2012, BW)
%
%Example:
%
%    ieGetXYCoords(vcGetObject('OI'));
%    sceneWindow; [xy, b] = ieGetXYCoords(vcGetObject('scene'));
%
% See also:  vcLineSelect, vcPointSelect
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
if ieNotDefined('objFig'), objFig = vcGetFigure(obj); end

% Figure out the figure associated with this object type
if isfield(obj,'type'), t = obj.type; 
else error('No object type field');
end

switch t
    case 'scene'
        objFig = ieSessionGet('scene figure');
    case 'opticalimage'
        objFig = ieSessionGet('oi figure');
    case 'sensor'
        objFig = ieSessionGet('sensor figure');
    case 'vcimage'
        objFig = ieSessionGet('vcimage figure');
    otherwise
        error('Bad object type %s\n',t);
end

% Bring up the figure, get the handles, put up a message
figure(objFig);
hndl = guihandles(objFig);
ieInWindowMessage('Select line. Right click to end.',hndl);

% Click for the xy position
[x,y] = getpts(objFig);
xy = [round(x(end)),round(y(end))];

ieInWindowMessage('',hndl);

return;
