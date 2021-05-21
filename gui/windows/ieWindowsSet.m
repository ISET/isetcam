function wPos = ieWindowsSet(wPos, wState)
% Set current window positions and sizes
%
%  wPos = ieWindowsSet([wPos], wState)
%
% Place and size the windows in location stored in the rects specified in
% wPos, or in the Matlab prefs, or in a wPos variable in a file.
%
% wPos: Cell array of window positions, or
%         - If not defined, the positions are retrieved using
%          getpref('ISET','wPos'), or
%         - If a string, wPos should be a file containing the wPos variable
%
% wState: Optional boolean indicating whether to also restore window state
%
% See also: ieWindowsGet
%
% Example
%   ieWindowsSet;                % Return to ISET pref setting
%   ieWindowsSet('wPosVideo');   % Get the video positions and save them
%   ieWindowsSet('wPosWork');    % Get the work positions and save them
%
%   To establish a set of wPos values, do this:
%    * Set the window positions
%    * wPos = ieWindowsGet(true);
%    * save fullfile(isetRootPath,'gui','windows','wPosName') wPos
%
% Copyright Imageval Consulting, LLC 2013


%% The window positions are stored in the Matlab pref structure

% By default, we get the preferred positions and put any open windows there
if ieNotDefined('wPos') || isempty(wPos), wPos = getpref('ISET','wPos'); end

% movegui should just make sure we are on screen, but it actually seems
% to move the windows again in many cases, which is a waste of time.
% so for now we disable it:
screenProtect = false;

if ~exist('wState', 'var') || isempty(wState)
    wState = getpref('ISET','wState', []);
    restoreState = false;
else
    restoreState = true;
    if wState == true
        wState = getpref('ISET','wState', []);
    end
end

% If a file name is passed, then we read wPos from that file and put the
% windows there.
if ischar(wPos)
    % File name
    [p,n,e] = fileparts(wPos); if isempty(e), e = '.mat'; end
    wPos = fullfile(p,[n,e]);
    if exist(wPos,'file'), load(wPos,'wPos');
    else,                  error('No file %s\n',wPos);
    end
end

%% If the window is created and there is a stored value, set the window

w = ieSessionGet('main window'); v = wPos{1};
if ~isempty(w) && ~isempty(v) && isvalid(w)
    w.figure1.Position = v;
    if screenProtect, movegui(w.figure1); end
    if restoreState && ~isempty(wState) && numel(wState) >= 1
        if ~isempty(wState{1}), w.figure1.WindowState = wState{1}; end
    end
end

w = ieSessionGet('scene window'); v = wPos{2};
if ~isempty(w) && ~isempty(v) && isvalid(w)
    w.figure1.Position = v;
    if screenProtect, movegui(w.figure1); end
    if restoreState && ~isempty(wState) && numel(wState) >= 2
        if ~isempty(wState{2}), w.figure1.WindowState = wState{2}; end
    end
end

w = ieSessionGet('oi window'); v = wPos{3};
if ~isempty(w) && ~isempty(v) && isvalid(w)
    w.figure1.Position = v;
    if screenProtect, movegui(w.figure1); end
    if restoreState && ~isempty(wState) && numel(wState) >= 3
        if ~isempty(wState{3}), w.figure1.WindowState = wState{3}; end
    end
end

w = ieSessionGet('sensor window');v = wPos{4};
if ~isempty(w) && ~isempty(v) && isvalid(w)
    w.figure1.Position = v;
    if screenProtect, movegui(w.figure1); end
    if restoreState && ~isempty(wState) && numel(wState) >= 4
        if ~isempty(wState{4}), w.figure1.WindowState = wState{4}; end
    end
end

w = ieSessionGet('ip window');v = wPos{5};
if ~isempty(w) && ~isempty(v) && isvalid(w)
    w.figure1.Position = v;
    if screenProtect, movegui(w.figure1); end
    if restoreState && ~isempty(wState) && numel(wState) >= 5
        if ~isempty(wState{5}), w.figure1.WindowState = wState{5}; end
    end
end

if numel(wPos) > 5
    w = ieSessionGet('camdesign window');v = wPos{6};
    if ~isempty(w) && ~isempty(v) && isvalid(w)
        w.figure1.Position = v;
        if screenProtect, movegui(w.figure1); end
        if restoreState && ~isempty(wState) && numel(wState) >= 6
            if ~isempty(wState{6}), w.figure1.WindowState = wState{6}; end
        end
    end
end

if numel(wPos) > 6
    w = ieSessionGet('imageexplore window');v = wPos{7};
    if ~isempty(w) && ~isempty(v) && isvalid(w)
        w.UIFigure.Position = v;
        if screenProtect, movegui(w.UIFigure); end
        if restoreState && ~isempty(wState) && numel(wState) >= 7
            if ~isempty(wState{7}), w.UIFigure.WindowState = wState{7}; end
        end
    end
end

setpref('ISET','wPos',wPos);
% not sure if/when we need to store State here since we use
% WindowsGet(true)

end

