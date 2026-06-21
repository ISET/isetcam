function run = ieExamplesTest(selector)
% Run ISETCam examples through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieExamplesTest
%   run = ieExamplesTest(selector)

if nargin < 1, selector = ''; end

config = struct();
config.repositoryName = 'ISETCam';
config.repositoryRoot = isetRootPath;
config.suiteKind = 'examples';
config.runnerName = mfilename;
config.selector = selector;
config.skipPathPatterns = { ...
    [filesep 'data' filesep], ...
    ['scripts' filesep 'image' filesep 'jpegFiles'], ...
    ['scripts' filesep 'optics' filesep 'chromAb']};
config.conditionalSkipFcn = @localConditionalSkip;

run = ieRunTutorialExampleTests(config);

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
