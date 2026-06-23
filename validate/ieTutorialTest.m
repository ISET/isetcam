function run = ieTutorialTest(varargin)
% Run ISETCam tutorials through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieTutorialTest
%   run = ieTutorialTest('selection',scriptName)
%   run = ieTutorialTest('start',scriptName)
%
% With no arguments, all tutorials run. 'selection' runs only scriptName;
% 'start' runs scriptName and every tutorial after it.

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
%% Parse the public selection options.

selector = '';
start = '';
if isempty(varargin), return; end
if numel(varargin) ~= 2
    error('ieTutorialTest:InvalidInput', ...
        'Use no arguments or one name-value pair: selection or start.');
end

option = lower(char(varargin{1}));
switch option
    case 'selection'
        selector = varargin{2};
    case 'start'
        start = varargin{2};
    otherwise
        error('ieTutorialTest:InvalidOption', ...
            'Unknown option "%s". Use selection or start.',option);
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
