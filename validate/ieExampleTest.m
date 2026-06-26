function run = ieExampleTest(varargin)
% Run ISETCam examples through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieExampleTest
%   run = ieExampleTest('selection',scriptName)
%   run = ieExampleTest('start',scriptName)
%
% With no arguments, all examples run. 'selection' runs only scriptName;
% 'start' runs scriptName and every example after it.

[selector,start] = localParseSelection(varargin{:});

config = struct();
config.repositoryName = 'ISETCam';
config.repositoryRoot = isetRootPath;
config.suiteKind = 'examples';
config.runnerName = mfilename;
config.selector = selector;
config.start = start;
config.skipPathPatterns = { ...
    [filesep 'data' filesep], ...
    ['scripts' filesep 'image' filesep 'jpegFiles'], ...
    ['scripts' filesep 'optics' filesep 'chromAb']};
config.conditionalSkipFcn = @localConditionalSkip;

run = ieRunTutorialExampleTests(config);

end

function [selector,start] = localParseSelection(varargin)
%% Parse the public selection options.

selector = '';
start = '';
if isempty(varargin), return; end
if numel(varargin) ~= 2
    error('ieExampleTest:InvalidInput', ...
        'Use no arguments or one name-value pair: selection or start.');
end

option = lower(char(varargin{1}));
switch option
    case 'selection'
        selector = varargin{2};
    case 'start'
        start = varargin{2};
    otherwise
        error('ieExampleTest:InvalidOption', ...
            'Unknown option "%s". Use selection or start.',option);
end

end

function reason = localConditionalSkip(filePath)
%% Skip preference-sensitive GUI examples in restricted sessions.

reason = '';
[~,fileName] = fileparts(filePath);
if ~strcmp(fileName,'s_initFont'), return; end
if ~usejava('desktop') || localCannotLoadPrefs()
    reason = 'preference-sensitive GUI example in a restricted session';
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
