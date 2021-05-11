function [wPos, wState] = ieWindowsGet(saveFlag)
% Find current window positions and sizes
%
%  wPos = ieWindowsGet(saveFlag);
%
% The current object window positions are returned in a cell array.
%
% If saveFlag is true, then the object window positions and sizes are
% stored in a Matlab environment variable ('ISET','wPos')
%
% See also: ieWindowsSet, s_initWindows (tutorial)
%
% Example:
%  wPos = ieWindowsGet; % Find positions of open windows
%  save wPos fullfile(isetRootpath,'gui','windows',<wPosFileName>');
%  ieWindowsGet(true);  % Find positions and save in ISET prefs
%
%
% Copyright Imageval Consulting, LLC 2013

if ieNotDefined('saveFlag'), saveFlag = false; end

wState = [];
wPos = ieSessionGet('wpos');

w = ieSessionGet('main window');
if ~isempty(w) && isvalid(w)
    wPos{1} = w.figure1.Position;
    wState{1} = w.figure1.WindowState;
end

w = ieSessionGet('scene window');
if ~isempty(w) && isvalid(w)
    wPos{2} = w.figure1.Position;
    wState{2} = w.figure1.WindowState;
end

w = ieSessionGet('oi window');
if ~isempty(w) && isvalid(w)
    wPos{3} = w.figure1.Position;
    wState{3} = w.figure1.WindowState;
end

w = ieSessionGet('sensor window');
if ~isempty(w) && isvalid(w)
    wPos{4} = w.figure1.Position;
    wState{4} = w.figure1.WindowState;
end

w = ieSessionGet('ip window');
if ~isempty(w) && isvalid(w)
    wPos{5} = w.figure1.Position;
    wState{5} = w.figure1.WindowState;
end

% w = ieSessionGet('graph window');
% if ~isempty(w), wPos{6} = w.figure1.Position; end
w = ieSessionGet('camdesign window');
if ~isempty(w) && isvalid(w)
    wPos{6} = w.figure1.Position;
    wState{6} = w.figure1.WindowState;
end

w = ieSessionGet('imageexplore window');
if ~isempty(w) && isvalid(w)
    wPos{7} = w.UIFigure.Position;
    wState{7} = w.UIFigure.WindowState;
end


if saveFlag
    setpref('ISET', 'wPos', wPos);
    setpref('ISET', 'wState', wState);
end

end
