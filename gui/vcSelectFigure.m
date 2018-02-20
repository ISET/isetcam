function figNum = vcSelectFigure(objType,noNewWin)
% Open an ISET window and return a figure number 
%
%   figNum = vcSelectFigure(objType,noNewWin)
%
% If the ISET figure is already open, the existing figure number is
% returned.  If the ISET window is not opened, then the function that opens
% the window is called and the new figure number is returned.
%
% You can suppress opening a window  by setting noNewWin = 1. In that case,
% if no window exists figNum will be returned empty and no window will be
% opened.
%
% Example:
%  figNum = vcSelectFigure('GRAPHWIN');
%  figNum = vcSelectFigure('scene',1);
%  figNum = vcSelectFigure('scene');
%  figNum = vcSelectFigure('oi');
%  figure(vcSelectFigure('ISA'));
%
% Copyright ImagEval Consultants, LLC, 2005.


% figNum = [];

% By default, we assume that the user DOES want a new graph window when
% this routine is called.  To suppress the call, and return an empty
% figNum, you must set noNewWin to 1 in the call.
if ~exist('noNewWin','var'), noNewWin = 0; end
objType = vcEquivalentObjtype(objType);

switch lower(objType)
    case 'graphwin'
        figNum = ieSessionGet('graph win figure');
        if isempty(figNum) && ~noNewWin, figNum = vcNewGraphWin;  end
        
    case 'scene'
        figNum = ieSessionGet('scene window');
        if isempty(figNum) && ~noNewWin, figNum = sceneWindow; end
        
    case {'opticalimage'}
        figNum = ieSessionGet('oi window');
        if isempty(figNum) && ~noNewWin, figNum = oiWindow; end
        
    case {'isa'}
        figNum = ieSessionGet('sensor window');
        if isempty(figNum) && ~noNewWin, figNum = sensorImageWindow; end
        
    case {'vcimage'}
        figNum = ieSessionGet('vcimage window');
        if isempty(figNum) && ~noNewWin, figNum = ipWindow; end
        
    otherwise
        error('Unknown window type.');
end

return;

