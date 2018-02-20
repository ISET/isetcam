function wPos = ieWindowsGet(saveFlag)
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
    
wPos = ieSessionGet('wpos');

w = ieSessionGet('main window');
if ~isempty(w), wPos{1} = get(w,'Position'); end
wPos{1} = get(w,'Position');

w = ieSessionGet('scene window');
if ~isempty(w), wPos{2} = get(w,'Position'); end

w = ieSessionGet('oi window');
if ~isempty(w), wPos{3} = get(w,'Position'); end

w = ieSessionGet('sensor window');
if ~isempty(w), wPos{4} = get(w,'Position'); end

w = ieSessionGet('ip window');
if ~isempty(w), wPos{5} = get(w,'Position'); end

w = ieSessionGet('graph window');
if ~isempty(w), wPos{6} = get(w,'Position'); end

if saveFlag, setpref('ISET','wPos',wPos);  end

end

