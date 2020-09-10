function wPos = ieWindowsSet(wPos)
% Set current window positions and sizes
%
%  wPos = ieWindowsSet([wPos])
%
% Place and size the windows in location stored in the rects specified in
% wPos, or in the Matlab prefs, or in a wPos variable in a file.
%
% wPos: Cell array of window positions, or
%         - If not defined, the positions are retrieved using
%          getpref('ISET','wPos'), or
%         - If a string, wPos should be a file containing the wPos variable
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
if ieNotDefined('wPos'), wPos = getpref('ISET','wPos'); end

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
if ~isempty(w) && ~isempty(v), w.figure1.Position = v; end

w = ieSessionGet('scene window'); v = wPos{2};
if ~isempty(w) && ~isempty(v), w.figure1.Position = v; end

w = ieSessionGet('oi window'); v = wPos{3};
if ~isempty(w) && ~isempty(v), w.figure1.Position = v; end

w = ieSessionGet('sensor window');v = wPos{4};
if ~isempty(w) && ~isempty(v), w.figure1.Position = v; end

w = ieSessionGet('ip window');v = wPos{5};
if ~isempty(w) && ~isempty(v), w.figure1.Position = v; end

% if size(wPos) > 5
%     w = ieSessionGet('graph window');v = wPos{6};
%     if ~isempty(w) && ~isempty(v), set(w,'Position',v); end
% end

setpref('ISET','wPos',wPos);

end

