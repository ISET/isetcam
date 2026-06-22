function run = ieExamplesTest(varargin)
% Run ISETCam examples through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieExamplesTest
%   run = ieExamplesTest('select',scriptName)
%   run = ieExamplesTest('start',scriptName)
%
% With no arguments, all examples run.  'select' runs only scriptName;
% 'start' runs scriptName and every example after it.  A single scriptName
% argument remains supported as the legacy form of 'select'.

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
%% Parse the public selection options while retaining legacy calls.

selector = '';
start = '';
if isempty(varargin), return; end
if isscalar(varargin)
    selector = varargin{1};
    return;
end
if numel(varargin) ~= 2
    error('ieExamplesTest:InvalidInput', ...
        'Use no arguments or one name-value pair: select or start.');
end

option = lower(char(varargin{1}));
switch option
    case {'select','selector'}
        selector = varargin{2};
    case 'start'
        start = varargin{2};
    otherwise
        error('ieExamplesTest:InvalidOption', ...
            'Unknown option "%s". Use select or start.',option);
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
