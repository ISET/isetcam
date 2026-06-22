function run = ieTutorialsTest(varargin)
% Run ISETCam tutorials through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieTutorialsTest
%   run = ieTutorialsTest('select',scriptName)
%   run = ieTutorialsTest('start',scriptName)
%
% With no arguments, all tutorials run.  'select' runs only scriptName;
% 'start' runs scriptName and every tutorial after it.  A single scriptName
% argument remains supported as the legacy form of 'select'.

[selector,start] = localParseSelection(varargin{:});

config = struct();
config.repositoryName = 'ISETCam';
config.repositoryRoot = isetRootPath;
config.suiteKind = 'tutorials';
config.runnerName = mfilename;
config.selector = selector;
config.start = start;
config.skipPathPatterns = { ...
    [filesep 'data' filesep], ...
    ['hyperspectral' filesep 'support']};
config.conditionalSkipFcn = @localConditionalSkip;

run = ieRunTutorialExampleTests(config);

end

function [selector,start] = localParseSelection(varargin)
%% Parse the public selection options while retaining legacy calls.

selector = '';
start = '';
if isempty(varargin), return; end
if isscalar(varargin)
    selector = varargin{1};
    return;
end
if numel(varargin) ~= 2
    error('ieTutorialsTest:InvalidInput', ...
        'Use no arguments or one name-value pair: select or start.');
end

option = lower(char(varargin{1}));
switch option
    case {'select','selector'}
        selector = varargin{2};
    case 'start'
        start = varargin{2};
    otherwise
        error('ieTutorialsTest:InvalidOption', ...
            'Unknown option "%s". Use select or start.',option);
end

end

function reason = localConditionalSkip(filePath)
%% Skip preference-sensitive GUI tutorials in restricted sessions.

reason = '';
[~,fileName] = fileparts(filePath);
if ~strcmp(fileName,'t_guiISETPref'), return; end
if ~usejava('desktop') || localCannotLoadPrefs()
    reason = 'preference-sensitive GUI tutorial in a restricted session';
end

end

function tf = localCannotLoadPrefs
%% Detect environments where MATLAB preferences cannot be read safely.

tf = false;
try
    getpref('ISET','waitbar',true);
catch
    tf = true;
end

end
