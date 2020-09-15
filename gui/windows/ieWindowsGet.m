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
if ~isempty(w) && isvalid(w), wPos{1} = w.figure1.Position; end

w = ieSessionGet('scene window');
if ~isempty(w) && isvalid(w), wPos{2} = w.figure1.Position; end

w = ieSessionGet('oi window');
if ~isempty(w) && isvalid(w), wPos{3} = w.figure1.Position; end

w = ieSessionGet('sensor window');
if ~isempty(w) && isvalid(w), wPos{4} = w.figure1.Position; end

w = ieSessionGet('ip window');
if ~isempty(w) && isvalid(w), wPos{5} = w.figure1.Position; end

% w = ieSessionGet('graph window');
% if ~isempty(w), wPos{6} = w.figure1.Position; end
w = ieSessionGet('camdesign window');
if ~isempty(w) && isvalid(w), wPos{6} = w.figure1.Position; end

w = ieSessionGet('imageexplore window');
if ~isempty(w) && isvalid(w), wPos{7} = w.UIFigure.Position; end


if saveFlag, setpref('ISET','wPos',wPos);  end

end

